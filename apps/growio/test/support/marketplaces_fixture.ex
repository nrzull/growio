defmodule Growio.MarketplacesFixture do
  alias Growio.Marketplaces
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias Growio.Accounts.Account
  alias Growio.Utils

  def marketplace!(%Account{} = account) do
    {:ok, result} =
      Marketplaces.create_marketplace(account, %{
        name: "marketplace #{Utils.gen_integer(1..6)}"
      })

    result
  end

  def role!(%Marketplace{} = marketplace) do
    {:ok, result} =
      Marketplaces.create_account_role(marketplace, %{name: "role #{Utils.gen_integer(1..6)}"})

    result
  end

  def item_category!(%Marketplace{} = marketplace, params \\ %{}) do
    {:ok, result} =
      Marketplaces.create_item_category(
        marketplace,
        Map.merge(
          %{name: "category #{Utils.gen_integer(1..6)}"},
          params
        )
      )

    result
  end

  def item!(%MarketplaceItemCategory{} = category) do
    {:ok, result} =
      Marketplaces.create_item(category, %{name: "item #{Utils.gen_integer(1..6)}"})

    result
  end

  def market!(%Marketplace{} = marketplace) do
    {:ok, result} =
      Marketplaces.create_market(marketplace, %{
        address: "market #{Utils.gen_integer(1..6)}"
      })

    result
  end
end
