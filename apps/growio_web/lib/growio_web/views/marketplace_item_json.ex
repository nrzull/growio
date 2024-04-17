defmodule GrowioWeb.Views.MarketplaceItemJSON do
  alias Growio.Marketplaces.MarketplaceItem

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceItem{} = value) do
    %{
      id: value.id,
      name: value.name,
      origin_id: value.origin_id,
      category_id: value.category_id
    }
  end

  def render(_value), do: nil
end
