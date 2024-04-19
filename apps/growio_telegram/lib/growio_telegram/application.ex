defmodule GrowioTelegram.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {
        DynamicSupervisor,
        strategy: :one_for_one, name: GrowioTelegram.DynamicSupervisor
      },
      {
        GrowioTelegram.Interface,
        nil
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: GrowioTelegram.Supervisor)
  end
end
