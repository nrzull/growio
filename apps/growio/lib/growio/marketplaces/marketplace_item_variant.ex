defmodule Growio.Marketplaces.MarketplaceItemVariant do
  use Ecto.Schema
  alias Growio.Marketplaces.MarketplaceItem

  @type t :: %__MODULE__{}

  schema "marketplace_item_variants" do
    belongs_to(:item, MarketplaceItem)
    belongs_to(:variant, MarketplaceItem)

    timestamps()
  end
end
