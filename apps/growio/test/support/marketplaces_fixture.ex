defmodule Growio.MarketplacesFixture do
  alias Growio.Marketplaces
  alias Growio.Marketplaces.Marketplace
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
end
