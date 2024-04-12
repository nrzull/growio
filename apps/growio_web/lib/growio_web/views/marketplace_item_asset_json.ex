defmodule GrowioWeb.Views.MarketplaceItemAssetJSON do
  alias Growio.Marketplaces.MarketplaceItemAsset

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceItemAsset{} = value) do
    %{
      id: value.id,
      src: value.src,
      mimetype: value.mimetype
    }
  end

  def render(_value), do: nil
end
