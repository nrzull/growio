defmodule GrowioTelegram.MarketBot do
  @moduledoc false

  use Telegram.ChatBot

  alias Growio.Marketplaces
  alias GrowioTelegram.MarketBotRegistry
  alias Growio.Marketplaces.MarketplaceTelegramBot
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomer

  @session_ttl 60 * 1_000 * 10
  @max_bot_concurrency 999_999
  @market_url Application.compile_env!(:growio_telegram, :market_url)

  def update_bot(%MarketplaceTelegramBot{token: token} = bot) do
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

    with bot = %MarketplaceTelegramBot{} <-
           Marketplaces.get_telegram_bot(:token, token),
         result <-
           DynamicSupervisor.start_child(
             GrowioTelegram.DynamicSupervisor,
             {Telegram.Poller, bots: bots}
           ),
         true <- match?({:ok, _}, result) or match?({:ok, _, _}, result) do
      [_, pid | _] = Tuple.to_list(result)
      MarketBotRegistry.register(token, pid)

      with {:ok, %{"username" => username}} <- Telegram.Api.request(token, "getMe"),
           true <- bot.tag != username do
        Marketplaces.update_telegram_bot(bot, %{tag: username})
      end

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
    with bot = %MarketplaceTelegramBot{} <-
           Marketplaces.get_telegram_bot(:token, token) do
      Marketplaces.create_telegram_bot_customer(bot, %{chat_id: chat_id})

      if is_bitstring(bot.welcome_message) do
        Telegram.Api.request(token, "sendMessage", text: bot.welcome_message, chat_id: chat_id)
      end

      with customer = %MarketplaceTelegramBotCustomer{} <-
             Marketplaces.get_telegram_bot_customer(bot, chat_id),
           {:ok, order} = Marketplaces.create_order(customer) do
        url =
          URI.parse(@market_url)
          |> URI.append_path("/#{order.id}")
          |> URI.to_string()

        text =
          "[Created a new session for your shopping. Click on me to check what we have for you!](#{url})\n\n```#{order.id}```"

        text = if Mix.env() == :dev, do: "#{text}\n\n`#{url}`", else: text

        Telegram.Api.request(token, "sendMessage",
          text: text,
          chat_id: chat_id,
          parse_mode: "Markdown"
        )
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
