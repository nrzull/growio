defmodule GrowioWeb.Views.MarketplaceItemJSON do
  alias Growio.Marketplaces.MarketplaceItem

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceItem{} = value) do
    %{
      id: value.id,
      name: value.name,
      description: value.description,
      infinity: value.infinity,
      quantity: value.quantity,
      origin_id: value.origin_id,
      price: value.price,
      category_id: value.category_id
    }
  end

  def render(_value), do: nil
end
