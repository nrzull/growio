defmodule GrowioWeb.Controllers.MarketplaceWarehouseController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceWarehouseJSON
  alias Growio.Marketplaces

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_warehouses"])

  operation(:index,
    summary: "show marketplace warehouses",
    responses: [ok: {"", "application/json", Schemas.MarketplaceWarehouses}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    with warehouses when is_list(warehouses) <- Marketplaces.all_warehouses(marketplace_account) do
      Conn.ok(conn, MarketplaceWarehouseJSON.render(warehouses))
    end
  end

  operation(:create,
    summary: "create marketplace warehouse",
    request_body: {"", "application/json", Schemas.MarketplaceWarehouseCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceWarehouse}]
  )

  def create(%{assigns: %{marketplace_account: marketplace_account}} = conn, params) do
    with {:ok, warehouse} <- Marketplaces.create_warehouse(marketplace_account, params) do
      Conn.ok(conn, MarketplaceWarehouseJSON.render(warehouse))
    end
  end
end
