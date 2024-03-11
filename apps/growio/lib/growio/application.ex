defmodule Growio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Growio.Repo,
      {DNSCluster, query: Application.get_env(:growio, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Growio.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Growio.Finch}
      # Start a worker by calling: Growio.Worker.start_link(arg)
      # {Growio.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Growio.Supervisor)
  end
end
