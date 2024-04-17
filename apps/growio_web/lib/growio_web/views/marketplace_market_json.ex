defmodule GrowioWeb.Views.MarketplaceMarketJSON do
  alias Growio.Marketplaces.MarketplaceMarket

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceMarket{} = value) do
    %{
      id: value.id,
      name: value.name,
      address: value.address
    }
  end

  def render(_value), do: nil
end
