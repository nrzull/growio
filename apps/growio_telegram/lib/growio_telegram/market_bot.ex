defmodule GrowioTelegram.MarketBot do
  @moduledoc false

  use Telegram.ChatBot

  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceMarketTelegramBot

  @session_ttl 60 * 1_000 * 10
  @max_bot_concurrency 999_999

  def start_bot(token) when is_bitstring(token) do
    bots = [
      {
        GrowioTelegram.MarketBot,
        token: token, max_bot_concurrency: @max_bot_concurrency
      }
    ]

    with bot = %MarketplaceMarketTelegramBot{} <-
           Marketplaces.get_market_telegram_bot(:token, token),
         result <-
           DynamicSupervisor.start_child(
             GrowioTelegram.DynamicSupervisor,
             {Telegram.Poller, bots: bots}
           ),
         true <- match?({:ok, _}, result) or match?({:ok, _, _}, result) do
      if is_bitstring(bot.name) do
        Telegram.Api.request(token, "setMyName", name: bot.name)
      end

      if is_bitstring(bot.description) do
        Telegram.Api.request(token, "setMyDescription", description: bot.description)
      end

      if is_bitstring(bot.short_description) do
        Telegram.Api.request(token, "setMyShortDescription", short_description: bot.description)
      end

      result
    else
      e ->
        response = {:error, "cannot start a bot"}
        IO.inspect([response, e])
        response
    end
  end

  @impl Telegram.ChatBot
  def init(_chat) do
    {:ok, %{action: nil}, @session_ttl}
  end

  @impl Telegram.ChatBot
  def handle_update(
        %{"message" => %{"text" => "/start", "chat" => %{"id" => chat_id}}} = _,
        token,
        state
      ) do
    with bot = %MarketplaceMarketTelegramBot{} <-
           Marketplaces.get_market_telegram_bot(:token, token) do
      Marketplaces.create_market_telegram_bot_customer(bot, %{chat_id: chat_id})

      if is_bitstring(bot.welcome_message) do
        Telegram.Api.request(token, "sendMessage", text: bot.welcome_message, chat_id: chat_id)
      end
    end

    {:ok, state, @session_ttl}
  end

  @impl Telegram.ChatBot
  def handle_update(update, _token, state) do
    IO.inspect(update)
    {:ok, state, @session_ttl}
  end

  @impl Telegram.ChatBot
  def handle_timeout(token, chat_id, state) do
    super(token, chat_id, state)
  end
end
