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

  # CAST

  @impl true
  def handle_cast({:connect_bot, token}, state) do
    MarketBot.start_bot(token)
    {:noreply, state}
  end

  def handle_cast({:update_bot, bot}, state) do
    MarketBot.update_bot(bot)
    {:noreply, state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end

  # CALL

  def handle_call({:reconnect_bot, old_token, new_token}, _, state) do
    MarketBot.restart_bot(old_token, new_token)
    {:reply, {:ok, new_token}, state}
  end

  @impl true
  def handle_call(_, _pid, state) do
    {:noreply, state}
  end

  defp web, do: Growio.Registry.lookup(GrowioWeb.Interface)
end
