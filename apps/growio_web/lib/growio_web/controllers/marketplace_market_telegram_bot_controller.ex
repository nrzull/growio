defmodule GrowioWeb.Controllers.MarketplaceMarketTelegramBotController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceMarketTelegramBotJSON
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceMarket
  alias Growio.Marketplaces.MarketplaceMarketTelegramBot

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_market_telegram_bots"])

  operation(:create,
    summary: "create marketplace market telegram bot",
    parameters: [
      market_id: [in: :path, description: "market id", type: :integer, example: 1]
    ],
    request_body:
      {"", "application/json", Schemas.MarketplaceMarketTelegramBotCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarketTelegramBot}]
  )

  def create(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"market_id" => market_id} = params
      ) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         {:ok, %MarketplaceMarketTelegramBot{} = bot} <-
           Marketplaces.create_market_telegram_bot(marketplace_account, params) do
      Conn.ok(conn, MarketplaceMarketTelegramBotJSON.render(bot))
    end
  end

  operation(:delete,
    summary: "delete marketplace market telegram bot",
    parameters: [
      market_id: [in: :path, description: "market id", type: :integer],
      id: [in: :path, description: "market telegram bot id", type: :integer]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarketTelegramBot}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"market_id" => market_id, "id" => id} = params
      ) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         id when is_integer(id) <- String.to_integer(id),
         market = %MarketplaceMarket{} <-
           Marketplaces.get_market(marketplace_account, id),
         {:ok, deleted_telegram_bot} <-
           Marketplaces.delete_market_telegram_bot(marketplace_account, market, id) do
      Conn.ok(conn, MarketplaceMarketTelegramBotJSON.render(deleted_telegram_bot))
    end
  end
end
