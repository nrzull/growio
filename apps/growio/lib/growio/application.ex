defmodule Growio.Application do
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
      Growio.Cache,
      Growio.Repo,
      {DNSCluster, query: Application.get_env(:growio, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Growio.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Growio.Finch},
      GrowioWeb.Telemetry,
      # Start a worker by calling: GrowioWeb.Worker.start_link(arg)
      # {GrowioWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      GrowioWeb.Endpoint,
      {GrowioWeb.Interface, nil},
      {DynamicSupervisor, strategy: :one_for_one, name: GrowioTelegram.DynamicSupervisor},
      {MarketBotRegistry, nil},
      {GrowioTelegram.Interface, nil}
      # Start a worker by calling: Growio.Worker.start_link(arg)
      # {Growio.Worker, arg}
    ]

    result = Supervisor.start_link(children, strategy: :one_for_one, name: Growio.Supervisor)

    Marketplaces.all_telegram_bots()
    |> Enum.each(fn bot -> MarketBot.start_bot(bot.token) end)

    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GrowioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
