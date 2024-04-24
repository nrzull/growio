defmodule GrowioWeb.Controllers.MarketplaceCustomerController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Repo
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceOrder
  alias GrowioWeb.Views.MarketplacePayloadJSON

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
         order = Repo.preload(order, [:marketplace, :telegram_bot_customer]),
         tree when is_list(tree) <- Marketplaces.all_items_tree(order.marketplace) do
      Conn.ok(conn, MarketplacePayloadJSON.render(%{order: order, items: tree}))
    end
  end
end
