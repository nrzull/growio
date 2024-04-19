defmodule Growio.Registry do
  def register(pid, name), do: Process.register(pid, name)
  def lookup(name), do: Process.whereis(name)
end
