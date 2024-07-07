defmodule GrowioWeb.Controllers.MarketplaceItemTreeController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces
  alias GrowioWeb.Views.MarketplaceItemTreeJSON

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_items_tree"])

  operation(:index,
    summary: "show marketplace items tree",
    responses: [ok: {"", "application/json", Schemas.MarketplaceItems}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    with tree when is_list(tree) <- Marketplaces.all_items_tree(marketplace_account, opts) do
      Conn.ok(conn, MarketplaceItemTreeJSON.render(tree))
    end
  end
end
