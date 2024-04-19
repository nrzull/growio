defmodule GrowioTelegram.Interface do
  use GenServer
  alias GrowioTelegram.MarketBot

  def web_cast(request) do
    with pid when is_pid(pid) <- web() do
      GenServer.cast(web(), request)
    end
  end

  def web_call(request) do
    with pid when is_pid(pid) <- web() do
      GenServer.call(web(), request)
    end
  end

  def start_link(default) do
    {:ok, pid} = GenServer.start_link(__MODULE__, default)
    Growio.Registry.register(pid, GrowioTelegram.Interface)
    {:ok, pid}
  end

  @impl true
  def init(_params) do
    {:ok, nil}
  end

  @impl true
  def handle_cast({:connect_bot, token}, state) do
    MarketBot.start_bot(token)
    {:noreply, state}
  end

  @impl true
  def handle_cast(_, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call(_, _pid, state) do
    {:noreply, state}
  end

  defp web, do: Growio.Registry.lookup(GrowioWeb.Interface)
end
