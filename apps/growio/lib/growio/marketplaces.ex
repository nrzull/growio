defmodule Growio.Marketplaces do
  import Ecto.Query
  alias Growio.Repo
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Marketplaces.MarketplaceAccountRole

  def get_marketplace_by(:id, id) when is_integer(id) do
    Repo.get(Marketplace, id)
  end

  def get_marketplace_by(:name, name) when is_bitstring(name) do
    Repo.one(from(m in Marketplace, where: m.name == ^name))
  end

  def create_marketplace(%{} = params) do
    Repo.insert(Marketplace.changeset(params))
  end
end
