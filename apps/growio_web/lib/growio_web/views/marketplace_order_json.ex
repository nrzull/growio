defmodule GrowioWeb.Views.MarketplaceOrderJSON do
  alias Growio.Marketplaces.MarketplaceOrder

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceOrder{} = value) do
    %{
      id: value.id,
      status: value.status,
      payload: value.payload,
      marketplace_id: value.marketplace_id,
      telegram_bot_customer_id: value.telegram_bot_customer_id
    }
  end

  def render(_value), do: nil
end
