defmodule GrowioWeb.Views.MarketplaceMarketOrderJSON do
  alias Growio.Marketplaces.MarketplaceMarketOrder

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceMarketOrder{} = value) do
    %{
      id: value.id,
      status: value.status,
      payload: value.payload,
      market_id: value.market_id,
      telegram_bot_customer_id: value.telegram_bot_customer_id
    }
  end

  def render(_value), do: nil
end
