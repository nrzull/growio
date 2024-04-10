defmodule GrowioWeb.Controllers.MarketplaceItemCategoryController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias GrowioWeb.Views.MarketplaceItemCategoryJSON
  alias Growio.Marketplaces

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_item_categories"])

  operation(:index,
    summary: "show marketplace item categories",
    responses: [ok: {"", "application/json", Schemas.MarketplaceItemCategories}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    with categories when is_list(categories) <-
           Marketplaces.all_item_categories(marketplace_account, opts) do
      categories
      |> MarketplaceItemCategoryJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:create,
    summary: "create marketplace item category",
    request_body: {"", "application/json", Schemas.MarketplaceItemCategoryCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceItemCategory}]
  )

  def create(%{assigns: %{marketplace_account: marketplace_account}} = conn, params) do
    with {:ok, category} <- Marketplaces.create_item_category(marketplace_account, params) do
      category
      |> MarketplaceItemCategoryJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:update,
    summary: "update marketplace item category",
    parameters: [
      id: [in: :path, description: "category id", type: :integer, example: 1]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceItemCategory, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceItemCategory}]
  )

  def update(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id} = params
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, id),
         {:ok, updated_category} <-
           Marketplaces.update_item_category(marketplace_account, category, params) do
      Conn.ok(conn, MarketplaceItemCategoryJSON.render(updated_category))
    end
  end

  operation(:delete,
    summary: "delete marketplace item category",
    parameters: [
      id: [in: :path, description: "category id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceItemCategory}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id}
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, id),
         {:ok, deleted_item_category} <-
           Marketplaces.delete_item_category(marketplace_account, category) do
      Conn.ok(conn, MarketplaceItemCategoryJSON.render(deleted_item_category))
    end
  end
end
