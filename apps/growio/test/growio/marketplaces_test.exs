defmodule Growio.MarketplacesTest do
  use Growio.DataCase
  alias Growio.AccountsFixture
  alias Growio.MarketplacesFixture
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceAccountRole

  @valid_name "marketplace name"

  describe "Growio.Marketplaces" do
    test "it should create role, marketplace and marketplace account" do
      account = AccountsFixture.account!()

      {:ok, %{marketplace: marketplace, marketplace_account: marketplace_account}} =
        Marketplaces.create_marketplace(account, %{name: @valid_name})

      assert marketplace.name == @valid_name
      assert marketplace_account.account_id == account.id
    end

    test "it should create account roles with incremented priorities" do
      account = AccountsFixture.account!()
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(account)

      {:ok, role1} = Marketplaces.create_account_role(marketplace, %{name: "role1"})

      {:ok, role2} = Marketplaces.create_account_role(marketplace, %{name: "role2"})

      {:ok, role3} = Marketplaces.create_account_role(marketplace, %{name: "role3"})

      assert role1.priority == 2
      assert role2.priority == 3
      assert role3.priority == 4
    end

    test "it should update role priorities" do
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, _} = Marketplaces.create_account_role(marketplace, %{name: "role1"})
      {:ok, _} = Marketplaces.create_account_role(marketplace, %{name: "role2"})
      {:ok, _} = Marketplaces.create_account_role(marketplace, %{name: "role3"})

      {:ok,
       [
         %MarketplaceAccountRole{name: "owner", priority: 0},
         %MarketplaceAccountRole{name: "role3", priority: 1},
         %MarketplaceAccountRole{name: "role2", priority: 2},
         %MarketplaceAccountRole{name: "role1", priority: 3}
       ]} =
        Marketplaces.update_priorities(marketplace, ["owner", "role3", "role2", "role1"])

      {:ok,
       [
         %MarketplaceAccountRole{name: "owner", priority: 0},
         %MarketplaceAccountRole{name: "role2", priority: 1},
         %MarketplaceAccountRole{name: "role3", priority: 2},
         %MarketplaceAccountRole{name: "role1", priority: 3}
       ]} =
        Marketplaces.update_priorities(marketplace, ["owner", "role2", "role3", "role1"])
    end

    test "it should set new role permissions" do
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      role = Marketplaces.get_account_role(marketplace, "owner")

      {:ok, _} =
        Marketplaces.set_account_role_permissions(role, [
          Growio.Permissions.Definitions.marketplaces__marketplace_item__create()
        ])
    end
  end

  describe "Growio.MarketplacesFixture" do
    test "marketplace!/1" do
      account = AccountsFixture.account!()

      assert match?(
               %{marketplace: _},
               MarketplacesFixture.marketplace!(account)
             )
    end
  end
end
