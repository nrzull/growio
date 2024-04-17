defmodule GrowioWeb.Controllers.MarketplaceMarketItemController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceMarketItemJSON
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Marketplaces.MarketplaceMarketItem
  alias Growio.Marketplaces.MarketplaceMarket

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_market_items"])

  operation(:index,
    summary: "show marketplace market items",
    parameters: [
      market_id: [in: :path, description: "market id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarketItems}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, %{
        "market_id" => market_id
      }) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         market = %MarketplaceMarket{} <-
           Marketplaces.get_market(marketplace_account, market_id),
         items when is_list(items) <-
           Marketplaces.all_market_items(marketplace_account, market) do
      Conn.ok(conn, MarketplaceMarketItemJSON.render(items))
    end
  end

  operation(:create,
    summary: "create marketplace market item",
    parameters: [
      market_id: [in: :path, description: "market id", type: :integer, example: 1]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceMarketItemCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarketItem}]
  )

  def create(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"market_id" => market_id, "marketplace_item_id" => marketplace_item_id} = params
      ) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         market = %MarketplaceMarket{} <-
           Marketplaces.get_market(marketplace_account, market_id),
         marketplace_item = %MarketplaceItem{} <-
           Marketplaces.get_item(marketplace_account, marketplace_item_id),
         {:ok, created_item} <-
           Marketplaces.create_market_item(
             marketplace_account,
             market,
             marketplace_item,
             params
           ) do
      Conn.ok(conn, MarketplaceMarketItemJSON.render(created_item))
    end
  end

  operation(:update,
    summary: "update marketplace market item",
    parameters: [
      market_id: [in: :path, description: "market id", type: :integer],
      id: [in: :path, description: "market item id", type: :integer]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceMarketItemUpdate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarketItem}]
  )

  def update(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"market_id" => market_id, "id" => id} = params
      ) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         id when is_integer(id) <- String.to_integer(id),
         item = %MarketplaceMarketItem{} <-
           Marketplaces.get_market_item(marketplace_account, id),
         {:ok, updated_item} <-
           Marketplaces.update_market_item(marketplace_account, item, params) do
      Conn.ok(conn, MarketplaceMarketItemJSON.render(updated_item))
    end
  end

  operation(:delete,
    summary: "delete marketplace market item",
    parameters: [
      market_id: [in: :path, description: "market id", type: :integer],
      id: [in: :path, description: "market item id", type: :integer]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarketItem}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"market_id" => market_id, "id" => id}
      ) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         id when is_integer(id) <- String.to_integer(id),
         item = %MarketplaceMarketItem{} <-
           Marketplaces.get_market_item(marketplace_account, id),
         {:ok, deleted_item} <-
           Marketplaces.delete_market_item(marketplace_account, item) do
      Conn.ok(conn, MarketplaceMarketItemJSON.render(deleted_item))
    end
  end
end
