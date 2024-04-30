defmodule GrowioWeb.Channels.CustomerChannel do
  use Phoenix.Channel

  def join("customer:messages", _msg, socket) do
    {:ok, socket}
  end
end
