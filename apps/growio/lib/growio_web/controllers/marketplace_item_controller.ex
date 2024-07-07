defmodule GrowioWeb.Controllers.MarketplaceItemController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias GrowioWeb.Views.MarketplaceItemJSON
  alias Growio.Marketplaces

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_items"])

  operation(:self_index,
    summary: "show all marketplace items",
    responses: [ok: {"", "application/json", Schemas.MarketplaceItems}]
  )

  def self_index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    with items when is_list(items) <-
           Marketplaces.all_items(marketplace_account, opts) do
      items
      |> MarketplaceItemJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:index,
    summary: "show marketplace items",
    parameters: [
      category_id: [in: :path, description: "category id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceItems}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, %{
        "category_id" => category_id
      }) do
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    with category_id when is_integer(category_id) <-
           String.to_integer(category_id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_id),
         items when is_list(items) <-
           Marketplaces.all_items(marketplace_account, category, opts) do
      items
      |> MarketplaceItemJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:create,
    summary: "create marketplace item",
    parameters: [
      category_id: [in: :path, description: "category id", type: :integer, example: 1]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceItemCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceItem}]
  )

  def create(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{
          "category_id" => category_id
        } = params
      ) do
    with category_id when is_integer(category_id) <-
           String.to_integer(category_id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_id),
         {:ok, item} <-
           Marketplaces.create_item(marketplace_account, category, params) do
      item
      |> MarketplaceItemJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:update,
    summary: "update marketplace item",
    parameters: [
      category_id: [in: :path, description: "category id", type: :integer, example: 1],
      id: [in: :path, description: "item id", type: :integer, example: 1]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceItem, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceItem}]
  )

  def update(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => item_id, "category_id" => category_id} = params
      ) do
    with category_id when is_integer(category_id) <-
           String.to_integer(category_id),
         item_id when is_integer(item_id) <- String.to_integer(item_id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_id),
         item = %MarketplaceItem{} <-
           Marketplaces.get_item(marketplace_account, category, item_id),
         {:ok, updated_item} <-
           Marketplaces.update_item(marketplace_account, item, params) do
      Conn.ok(conn, MarketplaceItemJSON.render(updated_item))
    end
  end

  operation(:delete,
    summary: "delete marketplace item",
    parameters: [
      category_id: [in: :path, description: "category id", type: :integer, example: 1],
      id: [in: :path, description: "item id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceItem}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => item_id, "category_id" => category_id}
      ) do
    with item_id when is_integer(item_id) <- String.to_integer(item_id),
         category_id when is_integer(category_id) <-
           String.to_integer(category_id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_id),
         item = %MarketplaceItem{} <-
           Marketplaces.get_item(marketplace_account, category, item_id),
         {:ok, deleted_item} <-
           Marketplaces.delete_item(marketplace_account, item) do
      Conn.ok(conn, MarketplaceItemJSON.render(deleted_item))
    end
  end
end
