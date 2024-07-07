defmodule GrowioWeb.Views.MarketplaceJSON do
  alias Growio.Marketplaces.Marketplace

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%Marketplace{} = value) do
    %{
      id: value.id,
      name: value.name,
      currency: value.currency,
      address: value.address
    }
  end

  def render(_value), do: nil
end
