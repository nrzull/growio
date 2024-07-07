defmodule GrowioWeb.Views.MarketplaceOrderJSON do
  alias Growio.Marketplaces.MarketplaceOrder

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceOrder{} = value) do
    %{
      id: value.id,
      status: value.status,
      items: value.items,
      currency: value.currency,
      payment_type: value.payment_type,
      payment_provider: value.payment_provider,
      delivery_type: value.delivery_type,
      delivery_provider: value.delivery_provider,
      delivery_address: value.delivery_address,
      marketplace_id: value.marketplace_id,
      telegram_bot_customer_id: value.telegram_bot_customer_id
    }
  end

  def render(_value), do: nil
end
