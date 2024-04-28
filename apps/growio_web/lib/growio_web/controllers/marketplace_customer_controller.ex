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

  def update_payload(
        conn,
        %{
          "payload" => _,
          "items" => _,
          "status" => "preparing",
          "payment_type" => "in_place",
          "delivery_type" => _
        } = params
      ) do
    do_update_payload(conn, params)
  end

  def update_payload(
        conn,
        %{
          "payload" => _,
          "items" => _,
          "status" => "need_payment",
          "payment_type" => "online",
          "delivery_type" => _
        } = params
      ) do
    do_update_payload(conn, params)
  end

  defp do_update_payload(
         conn,
         %{
           "payload" => payload,
           "status" => status,
           "items" => items,
           "payment_type" => payment_type,
           "delivery_type" => delivery_type
         } = params
       )
       when status in ["preparing", "need_payment"] do
    delivery_address = Map.get(params, "delivery_address")

    with order = %MarketplaceOrder{} <- Marketplaces.get_order(payload),
         true <- MarketplaceOrder.valid_status_change?(order.status, status),
         order = Repo.preload(order, [:marketplace]) do
      cond do
        delivery_type == "export" and is_nil(delivery_address) ->
          Conn.bad_request(conn)

        true ->
          with {:ok, updated_order} <-
                 Marketplaces.update_order(order, %{
                   "status" => status,
                   "currency" => order.marketplace.currency,
                   "items" => items,
                   "payment_type" => payment_type,
                   "delivery_type" => delivery_type,
                   "delivery_address" => delivery_address
                 }),
               {:ok, payload} <- prepare_payload(updated_order) do
            Conn.ok(conn, payload)
          end
      end
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
