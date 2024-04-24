defmodule GrowioWeb.Views.MarketplacePayloadJSON do
  alias Growio.Marketplaces.MarketplaceOrder
  alias GrowioWeb.Views.MarketplaceJSON
  alias GrowioWeb.Views.MarketplaceOrderJSON
  alias GrowioWeb.Views.MarketplaceItemTreeJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%{order: %MarketplaceOrder{} = order, items: items}) do
    %{
      marketplace: MarketplaceJSON.render(order.marketplace),
      order: MarketplaceOrderJSON.render(order),
      items: MarketplaceItemTreeJSON.render(items)
    }
  end

  def render(_value), do: nil
end
