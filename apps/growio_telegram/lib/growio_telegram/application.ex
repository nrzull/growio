defmodule GrowioTelegram.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Growio.Marketplaces
  alias GrowioTelegram.MarketBot
  alias GrowioTelegram.MarketBotRegistry

  @impl true
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: GrowioTelegram.DynamicSupervisor},
      {MarketBotRegistry, nil},
      {GrowioTelegram.Interface, nil}
    ]

    result =
      Supervisor.start_link(
        children,
        strategy: :one_for_one,
        name: GrowioTelegram.Supervisor
      )

    Marketplaces.all_telegram_bots()
    |> Enum.each(fn bot -> MarketBot.start_bot(bot.token) end)

    result
  end
end
