defmodule GrowioWeb.Controllers.MarketplaceItemController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias GrowioWeb.Views.MarketplaceItemJSON
  alias Growio.Marketplaces

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_items"])

  operation(:index,
    summary: "show marketplace items",
    responses: [ok: {"", "application/json", Schemas.MarketplaceItems}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, %{
        "category_item_id" => category_item_id
      }) do
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    with category_item_id when is_integer(category_item_id) <-
           String.to_integer(category_item_id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_item_id),
         items when is_list(items) <-
           Marketplaces.all_items(marketplace_account, category, opts) do
      items
      |> MarketplaceItemJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:create,
    summary: "create marketplace item",
    request_body: {"", "application/json", Schemas.MarketplaceItemCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceItem}]
  )

  def create(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{
          "category_item_id" => category_item_id
        } = params
      ) do
    with category_item_id when is_integer(category_item_id) <-
           String.to_integer(category_item_id),
         category = %MarketplaceItemCategory{} <-
           Marketplaces.get_item_category(marketplace_account, category_item_id),
         {:ok, %{item: item}} <-
           Marketplaces.create_item(marketplace_account, category, params) do
      item
      |> MarketplaceItemJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end
end
