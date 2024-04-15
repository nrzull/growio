defmodule GrowioWeb.Controllers.MarketplaceWarehouseItemController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceWarehouseItemJSON
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Marketplaces.MarketplaceWarehouse

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_warehouse_items"])

  operation(:index,
    summary: "show marketplace warehouse items",
    parameters: [
      warehouse_id: [in: :path, description: "warehouse id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceWarehouseItems}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, %{
        "warehouse_id" => warehouse_id
      }) do
    with warehouse_id when is_integer(warehouse_id) <- String.to_integer(warehouse_id),
         warehouse = %MarketplaceWarehouse{} <-
           Marketplaces.get_warehouse(marketplace_account, warehouse_id),
         items when is_list(items) <-
           Marketplaces.all_warehouse_items(marketplace_account, warehouse) do
      Conn.ok(conn, MarketplaceWarehouseItemJSON.render(items))
    end
  end

  operation(:create,
    summary: "create marketplace warehouse item",
    parameters: [
      warehouse_id: [in: :path, description: "warehouse id", type: :integer, example: 1]
    ],
    request_body:
      {"", "application/json", Schemas.MarketplaceWarehouseItemCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceWarehouseItem}]
  )

  def create(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"warehouse_id" => warehouse_id, "marketplace_item_id" => marketplace_item_id} = params
      ) do
    with warehouse_id when is_integer(warehouse_id) <- String.to_integer(warehouse_id),
         marketplace_item_id when is_integer(marketplace_item_id) <-
           (is_integer(marketplace_item_id) && marketplace_item_id) ||
             String.to_integer(marketplace_item_id),
         warehouse = %MarketplaceWarehouse{} <-
           Marketplaces.get_warehouse(marketplace_account, warehouse_id),
         marketplace_item = %MarketplaceItem{} <-
           Marketplaces.get_item(marketplace_account, marketplace_item_id),
         {:ok, created_item} <-
           Marketplaces.create_warehouse_item(
             marketplace_account,
             warehouse,
             marketplace_item,
             params
           ) do
      Conn.ok(conn, MarketplaceWarehouseItemJSON.render(created_item))
    end
  end
end
