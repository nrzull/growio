defmodule GrowioWeb.Views.MarketplaceWarehouseItemJSON do
  alias Growio.Marketplaces.MarketplaceWarehouseItem
  alias GrowioWeb.Views.MarketplaceItemJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceWarehouseItem{} = value) do
    %{
      id: value.id,
      infinity: value.infinity,
      quantity: value.quantity,
      marketplace_item_id: value.marketplace_item_id,
      marketplace_item:
        if marketplace_item = get_in(value, [Access.key(:marketplace_item)]) do
          MarketplaceItemJSON.render(marketplace_item)
        else
          nil
        end
    }
  end

  def render(_value), do: nil
end
