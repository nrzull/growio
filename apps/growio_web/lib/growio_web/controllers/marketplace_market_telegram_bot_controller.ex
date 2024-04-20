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

  operation(:index_self,
    summary: "get self marketplace market telegram bot",
    parameters: [
      market_id: [in: :path, description: "market id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarketTelegramBot}]
  )

  def index_self(%{assigns: %{marketplace_account: marketplace_account}} = conn, %{
        "market_id" => market_id
      }) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         market = %MarketplaceMarket{} <- Marketplaces.get_market(marketplace_account, market_id),
         bot = %MarketplaceMarketTelegramBot{} <-
           Marketplaces.get_market_telegram_bot(marketplace_account, market) do
      Conn.ok(conn, MarketplaceMarketTelegramBotJSON.render(bot))
    end
  end

  operation(:update_self,
    summary: "update self marketplace market telegram bot",
    parameters: [
      market_id: [in: :path, description: "market id", type: :integer]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceMarketTelegramBot, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceMarketTelegramBot}]
  )

  def update_self(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"market_id" => market_id} = params
      ) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         market = %MarketplaceMarket{} <- Marketplaces.get_market(marketplace_account, market_id),
         bot = %MarketplaceMarketTelegramBot{} <-
           Marketplaces.get_market_telegram_bot(marketplace_account, market),
         {:ok, updated_bot} <-
           Marketplaces.update_market_telegram_bot(marketplace_account, bot, params) do
      if bot.token === updated_bot.token do
        GrowioWeb.Interface.telegram_cast({:update_bot, updated_bot})
      else
        GrowioWeb.Interface.telegram_call({:reconnect_bot, bot.token, updated_bot.token})
        GrowioWeb.Interface.telegram_cast({:update_bot, updated_bot})
      end

      Conn.ok(conn, MarketplaceMarketTelegramBotJSON.render(updated_bot))
    end
  end

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
      GrowioWeb.Interface.telegram_cast({:connect_bot, bot.token})
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
        %{"market_id" => market_id, "id" => id}
      ) do
    with market_id when is_integer(market_id) <- String.to_integer(market_id),
         id when is_integer(id) <- String.to_integer(id),
         market = %MarketplaceMarket{} <-
           Marketplaces.get_market(marketplace_account, market_id),
         {:ok, deleted_telegram_bot} <-
           Marketplaces.delete_market_telegram_bot(marketplace_account, market, id) do
      Conn.ok(conn, MarketplaceMarketTelegramBotJSON.render(deleted_telegram_bot))
    end
  end
end
