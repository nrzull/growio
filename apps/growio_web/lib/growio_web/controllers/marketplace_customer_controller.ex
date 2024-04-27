defmodule GrowioWeb.Controllers.MarketplaceCustomerController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Repo
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceOrder
  alias GrowioWeb.Views.MarketplacePayloadJSON
  alias GrowioWeb.Views.MarketplaceTelegramBotJSON
  alias Growio.Marketplaces.MarketplaceTelegramBot

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["customers"])

  operation(:show_payload,
    summary: "show marketplace payload",
    parameters: [
      payload: [in: :path, description: "payload", type: :string]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplacePayload}]
  )

  def show_payload(conn, %{"payload" => payload}) do
    with order = %MarketplaceOrder{} <- Marketplaces.get_order(payload),
         {:ok, payload} <- prepare_payload(order) do
      Conn.ok(conn, payload)
    end
  end

  operation(:update_payload,
    summary: "show marketplace payload",
    parameters: [
      payload: [in: :path, description: "payload", type: :string]
    ],
    request_body: {"", "application/json"},
    responses: [ok: {"", "application/json", Schemas.MarketplacePayload}]
  )

  def update_payload(conn, %{
        "payload" => payload,
        "items" => items,
        "status" => "need_payment" = status
      }) do
    with order = %MarketplaceOrder{} <- Marketplaces.get_order(payload),
         true <- MarketplaceOrder.valid_status_change?(order.status, status),
         order = Repo.preload(order, [:marketplace]),
         {:ok, updated_order} <-
           Marketplaces.update_order(order, %{
             "status" => status,
             "payload" =>
               order.payload
               |> Map.put(:items, items)
               |> Map.put(:currency, order.marketplace.currency)
           }),
         {:ok, payload} = prepare_payload(updated_order) do
      Conn.ok(conn, payload)
    end
  end

  defp prepare_payload(order) do
    with order = Repo.preload(order, [:marketplace, :telegram_bot_customer]),
         tree when is_list(tree) <-
           Marketplaces.all_items_tree(order.marketplace, deleted_at: false) do
      integrations =
        order.marketplace
        |> Marketplaces.all_integrations()
        |> Enum.map(fn
          %MarketplaceTelegramBot{} = bot ->
            MarketplaceTelegramBotJSON.render(bot, take: [:tag])

          v ->
            v
        end)

      result =
        %{order: order, items: tree, integrations: integrations}
        |> MarketplacePayloadJSON.render()

      {:ok, result}
    end
  end
end
