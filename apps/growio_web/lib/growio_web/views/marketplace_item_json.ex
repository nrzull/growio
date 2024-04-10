defmodule GrowioWeb.Views.MarketplaceItemJSON do
  alias Growio.Marketplaces.MarketplaceItem

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceItem{} = item) do
    %{
      id: item.id,
      name: item.name
    }
  end

  def render(_value), do: nil
end
