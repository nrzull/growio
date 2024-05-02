defmodule GrowioWeb.Channels.CustomerChannel do
  use Phoenix.Channel
  alias GrowioWeb.Endpoint
  alias GrowioWeb.Views.MarketplaceTelegramBotCustomerMessageJSON

  def join("customer:messages", _msg, socket) do
    {:ok, socket}
  end

  def new_message(message) do
    Endpoint.broadcast(
      "customer:messages",
      "new_message",
      MarketplaceTelegramBotCustomerMessageJSON.render(message)
    )
  end
end
