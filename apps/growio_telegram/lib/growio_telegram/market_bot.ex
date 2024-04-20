defmodule GrowioTelegram.MarketBot do
  @moduledoc false

  use Telegram.ChatBot

  alias Growio.Marketplaces
  alias GrowioTelegram.MarketBotRegistry
  alias Growio.Marketplaces.MarketplaceMarketTelegramBot
  alias Growio.Marketplaces.MarketplaceMarketTelegramBotCustomer

  @session_ttl 60 * 1_000 * 10
  @max_bot_concurrency 999_999

  def update_bot(%MarketplaceMarketTelegramBot{token: token} = bot) do
    if is_bitstring(bot.description) do
      Telegram.Api.request(token, "setMyDescription", description: bot.description)
    end

    if is_bitstring(bot.short_description) do
      Telegram.Api.request(token, "setMyShortDescription",
        short_description: bot.short_description
      )
    end

    if is_bitstring(bot.name) do
      Telegram.Api.request(token, "setMyName", name: bot.name)
    end
  end

  def start_bot(token) when is_bitstring(token) do
    bots = [
      {
        GrowioTelegram.MarketBot,
        token: token, max_bot_concurrency: @max_bot_concurrency
      }
    ]

    with %MarketplaceMarketTelegramBot{} <-
           Marketplaces.get_market_telegram_bot(:token, token),
         result <-
           DynamicSupervisor.start_child(
             GrowioTelegram.DynamicSupervisor,
             {Telegram.Poller, bots: bots}
           ),
         true <- match?({:ok, _}, result) or match?({:ok, _, _}, result) do
      [_, pid | _] = Tuple.to_list(result)
      MarketBotRegistry.register(token, pid) |> IO.inspect()
      result
    else
      e ->
        response = {:error, "cannot start a bot"}
        IO.inspect([response, e])
        response
    end
  end

  def stop_bot(token) when is_bitstring(token) do
    with {:ok, pid} <- MarketBotRegistry.lookup(token) do
      MarketBotRegistry.unregister(token)
      DynamicSupervisor.stop(pid)
    end
  end

  def restart_bot(old_token, new_token) do
    stop_bot(old_token)
    start_bot(new_token)
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

      with customer = %MarketplaceMarketTelegramBotCustomer{} <-
             Marketplaces.get_market_telegram_bot_customer(bot, chat_id),
           {:ok, order} = Marketplaces.create_market_order(customer) do
        Telegram.Api.request(token, "sendMessage", text: order.id, chat_id: chat_id)
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
