defmodule GrowioTelegram.MarketBot do
  @moduledoc false

  use Telegram.ChatBot

  @session_ttl 60 * 1_000

  def start_bot(token) when is_bitstring(token) do
    bots = [
      {GrowioTelegram.MarketBot, token: token, max_bot_concurrency: 999_999}
    ]

    GrowioTelegram.DynamicSupervisor
    |> DynamicSupervisor.start_child({Telegram.Poller, bots: bots})
  end

  @impl Telegram.ChatBot
  def init(_chat) do
    {:ok, %{action: nil}, @session_ttl}
  end

  @impl Telegram.ChatBot
  def handle_timeout(token, chat_id, state) do
    super(token, chat_id, state)
  end

  @impl Telegram.ChatBot
  def handle_update(update, _token, state) do
    IO.inspect(update)

    {:ok, state, @session_ttl}
  end
end
