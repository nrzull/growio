defmodule GrowioTelegram.MarketBotRegistry do
  def child_spec(_) do
    Registry.child_spec(keys: :unique, name: __MODULE__)
  end

  def lookup(token) do
    Registry.lookup(__MODULE__, token)
    |> case do
      [{_, pid}] ->
        {:ok, pid}

      [] ->
        {:error, :not_found}
    end
  end

  def unregister(token) do
    Registry.unregister(__MODULE__, token)
  end

  def register(token, pid) when is_pid(pid) do
    Registry.register(__MODULE__, token, pid)
  end
end
