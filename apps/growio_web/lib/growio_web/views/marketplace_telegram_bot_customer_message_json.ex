defmodule GrowioWeb.Views.MarketplaceTelegramBotCustomerMessageJSON do
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomerMessage

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceTelegramBotCustomerMessage{} = value) do
    %{
      id: value.id,
      text: value.text,
      customer_id: value.customer_id,
      inserted_at: value.inserted_at,
      marketplace_account_id: value.marketplace_account_id
    }
  end

  def render(_value), do: nil
end
