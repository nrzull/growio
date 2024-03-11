defmodule Growio.MarketplacesTest do
  use Growio.DataCase
  alias Growio.AccountsFixture
  alias Growio.Marketplaces

  @valid_name "marketplace name"

  describe "Marketplace" do
    test "it should create role, marketplace and marketplace account" do
      account = AccountsFixture.account!()

      {:ok, %{marketplace: marketplace, marketplace_account: marketplace_account}} =
        Marketplaces.create_marketplace(account, %{name: @valid_name})

      assert marketplace.name == @valid_name
      assert marketplace_account.account_id == account.id
    end
  end
end
