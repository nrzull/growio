defmodule GrowioWeb.Views.MarketplaceTelegramBotCustomerJSON do
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomer

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceTelegramBotCustomer{} = value) do
    %{
      id: value.id,
      conversation: value.conversation,
      bot_id: value.bot_id
    }
  end

  def render(_value), do: nil
end
