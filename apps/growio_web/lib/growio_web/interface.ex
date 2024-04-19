defmodule GrowioWeb.Interface do
  use GenServer

  def start_link(default) do
    {:ok, pid} = GenServer.start_link(__MODULE__, default)
    Growio.Registry.register(pid, GrowioWeb.Interface)
    {:ok, pid}
  end

  def telegram_cast(request) do
    GenServer.cast(telegram(), request)
  end

  def telegram_call(request) do
    GenServer.call(telegram(), request)
  end

  @impl true
  def init(_params) do
    {:ok, nil}
  end

  @impl true
  def handle_cast(:hello, state) do
    IO.inspect(["HELLO WORLD from GrowioWeb.Interface"])
    {:noreply, state}
  end

  defp telegram, do: Growio.Registry.lookup(GrowioTelegram.Interface)
end
