defmodule GrowioWeb.Controllers.MarketplaceAccountItemCategoryController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceAccountItemCategoryJSON
  alias Growio.Marketplaces

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_account_item_categories"])

  operation(:index,
    summary: "show marketplace account item categories",
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountItemCategories}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    with categories when is_list(categories) <-
           Marketplaces.all_item_categories(marketplace_account) do
      categories
      |> MarketplaceAccountItemCategoryJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:create,
    summary: "create marketplace account item category",
    request_body:
      {"", "application/json", Schemas.MarketplaceAccountItemCategoryCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountItemCategory}]
  )

  def create(%{assigns: %{marketplace_account: marketplace_account}} = conn, params) do
    with {:ok, category} <- Marketplaces.create_item_category(marketplace_account, params) do
      category
      |> MarketplaceAccountItemCategoryJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end
end
