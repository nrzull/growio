defmodule GrowioWeb.Views.MarketplaceWarehouseJSON do
  alias Growio.Marketplaces.MarketplaceWarehouse

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceWarehouse{} = value) do
    %{
      id: value.id,
      name: value.name,
      address: value.address
    }
  end

  def render(_value), do: nil
end
