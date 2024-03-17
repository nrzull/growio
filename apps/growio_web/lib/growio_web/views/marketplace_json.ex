defmodule GrowioWeb.Views.MarketplaceJSON do
  alias Growio.Marketplaces.Marketplace

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%Marketplace{} = marketplace) do
    %{
      id: marketplace.id,
      name: marketplace.name
    }
  end
end
