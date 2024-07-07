defmodule GrowioWeb.Controllers.MarketplaceItemAssetController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias Growio.Marketplaces
  alias GrowioWeb.Conn
  alias GrowioWeb.Views.MarketplaceItemAssetJSON
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Marketplaces.MarketplaceItemAsset
  alias Growio.Marketplaces.MarketplaceItemCategory

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_item_assets"])

  operation(:index,
    summary: "show marketplace item assets",
    parameters: [
      category_id: [in: :path, description: "category id", type: :integer, example: 1],
      item_id: [in: :path, description: "item id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceItemAssets}]
  )

  def index(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"item_id" => item_id, "category_id" => category_id}
      ) do
    with category_id when is_integer(category_id) <-
           String.to_integer(category_id),
         item_id when is_integer(item_id) <- String.to_integer(item_id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_id),
         item = %MarketplaceItem{} <-
           Marketplaces.get_item(marketplace_account, category, item_id),
         assets when is_list(assets) <-
           Growio.Marketplaces.all_item_assets(marketplace_account, item) do
      Conn.ok(conn, MarketplaceItemAssetJSON.render(assets))
    end
  end

  operation(:create,
    summary: "create marketplace item asset",
    parameters: [
      category_id: [in: :path, description: "category id", type: :integer, example: 1],
      item_id: [in: :path, description: "item id", type: :integer, example: 1]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceItemAssetCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceItemAsset}]
  )

  def create(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"item_id" => item_id, "category_id" => category_id} = params
      ) do
    with category_id when is_integer(category_id) <-
           String.to_integer(category_id),
         item_id when is_integer(item_id) <- String.to_integer(item_id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_id),
         item = %MarketplaceItem{} <-
           Marketplaces.get_item(marketplace_account, category, item_id),
         {:ok, asset} <- Marketplaces.create_item_asset(marketplace_account, item, params) do
      Conn.ok(conn, MarketplaceItemAssetJSON.render(asset))
    end
  end

  operation(:delete,
    summary: "delete marketplace item asset",
    parameters: [
      category_id: [in: :path, description: "category id", type: :integer, example: 1],
      item_id: [in: :path, description: "item id", type: :integer, example: 1],
      id: [in: :path, description: "id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceItemAsset}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"item_id" => item_id, "category_id" => category_id, "id" => id}
      ) do
    with category_id when is_integer(category_id) <-
           String.to_integer(category_id),
         item_id when is_integer(item_id) <- String.to_integer(item_id),
         id when is_integer(id) <- String.to_integer(id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_id),
         item = %MarketplaceItem{} <-
           Marketplaces.get_item(marketplace_account, category, item_id),
         asset = %MarketplaceItemAsset{} <-
           Marketplaces.get_item_asset(marketplace_account, item, id),
         {:ok, deleted_asset} <- Marketplaces.delete_item_asset(marketplace_account, asset) do
      Conn.ok(conn, MarketplaceItemAssetJSON.render(deleted_asset))
    end
  end
end
