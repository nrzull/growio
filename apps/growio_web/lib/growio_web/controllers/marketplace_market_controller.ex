defmodule GrowioWeb.Controllers.MarketplaceMarketController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceMarketJSON
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceMarket

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_markets"])

  operation(:index,
    summary: "show marketplace markets",
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarkets}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    with markets when is_list(markets) <- Marketplaces.all_markets(marketplace_account) do
      Conn.ok(conn, MarketplaceMarketJSON.render(markets))
    end
  end

  operation(:show,
    summary: "show marketplace market",
    parameters: [
      id: [in: :path, description: "market id", type: :integer]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarket}]
  )

  def show(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id}
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         market = %MarketplaceMarket{} <-
           Marketplaces.get_market(marketplace_account, id) do
      Conn.ok(conn, MarketplaceMarketJSON.render(market))
    end
  end

  operation(:create,
    summary: "create marketplace market",
    request_body: {"", "application/json", Schemas.MarketplaceMarketCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarket}]
  )

  def create(%{assigns: %{marketplace_account: marketplace_account}} = conn, params) do
    with {:ok, market} <- Marketplaces.create_market(marketplace_account, params) do
      Conn.ok(conn, MarketplaceMarketJSON.render(market))
    end
  end

  operation(:update,
    summary: "update marketplace market",
    parameters: [
      id: [in: :path, description: "market id", type: :integer, example: 1]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceMarket, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarket}]
  )

  def update(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id} = params
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         market = %MarketplaceMarket{} <-
           Marketplaces.get_market(marketplace_account, id),
         {:ok, updated_market} <-
           Marketplaces.update_market(marketplace_account, market, params) do
      Conn.ok(conn, MarketplaceMarketJSON.render(updated_market))
    end
  end

  operation(:delete,
    summary: "delete marketplace market",
    parameters: [
      id: [in: :path, description: "market id", type: :integer]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarket}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id}
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         market = %MarketplaceMarket{} <-
           Marketplaces.get_market(marketplace_account, id),
         {:ok, deleted_market} <-
           Marketplaces.delete_market(marketplace_account, market) do
      Conn.ok(conn, MarketplaceMarketJSON.render(deleted_market))
    end
  end
end
