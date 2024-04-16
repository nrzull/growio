defmodule GrowioWeb.Controllers.MarketplaceWarehouseController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceWarehouseJSON
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceWarehouse

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

  operation(:update,
    summary: "update marketplace warehouse",
    parameters: [
      id: [in: :path, description: "warehouse id", type: :integer, example: 1]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceWarehouse, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceWarehouse}]
  )

  def update(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id} = params
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         warehouse = %MarketplaceWarehouse{} <-
           Marketplaces.get_warehouse(marketplace_account, id),
         {:ok, updated_warehouse} <-
           Marketplaces.update_warehouse(marketplace_account, warehouse, params) do
      Conn.ok(conn, MarketplaceWarehouseJSON.render(updated_warehouse))
    end
  end

  operation(:delete,
    summary: "delete marketplace warehouse",
    parameters: [
      id: [in: :path, description: "warehouse id", type: :integer]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceWarehouse}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id}
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         warehouse = %MarketplaceWarehouse{} <-
           Marketplaces.get_warehouse(marketplace_account, id),
         {:ok, deleted_warehouse} <-
           Marketplaces.delete_warehouse(marketplace_account, warehouse) do
      Conn.ok(conn, MarketplaceWarehouseJSON.render(deleted_warehouse))
    end
  end
end
