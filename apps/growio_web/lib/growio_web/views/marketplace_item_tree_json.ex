defmodule GrowioWeb.Views.MarketplaceItemTreeJSON do
  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%{children: children} = value) do
    %{
      id: value.id,
      name: value.name,
      parent_id: value.parent_id,
      children: render(children)
    }
  end

  def render(%{category_id: _} = value) do
    %{
      id: value.id,
      name: value.name,
      quantity: value.quantity,
      infinity: value.infinity,
      price: value.price,
      description: value.description,
      origin_id: value.origin_id,
      category_id: value.category_id
    }
  end

  def render(_value), do: nil
end
