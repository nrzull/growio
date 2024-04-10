defmodule GrowioWeb.Views.MarketplaceItemCategoryJSON do
  alias Growio.Marketplaces.MarketplaceItemCategory

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceItemCategory{} = category) do
    %{
      id: category.id,
      name: category.name
    }
  end

  def render(_value), do: nil
end
