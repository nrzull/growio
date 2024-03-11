defmodule Growio.MarketplacesTest do
  use Growio.DataCase
  alias Growio.AccountsFixture
  alias Growio.MarketplacesFixture
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Permissions.PermissionDefs

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

      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(account)

      {:ok, role1} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role1"})

      {:ok, role2} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role2"})

      {:ok, role3} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role3"})

      assert role1.priority == 2
      assert role2.priority == 3
      assert role3.priority == 4
    end

    test "it should update role priorities" do
      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, _} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role1"})

      {:ok, _} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role2"})

      {:ok, _} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role3"})

      {:ok,
       [
         %MarketplaceAccountRole{name: "owner", priority: 0},
         %MarketplaceAccountRole{name: "role3", priority: 1},
         %MarketplaceAccountRole{name: "role2", priority: 2},
         %MarketplaceAccountRole{name: "role1", priority: 3}
       ]} =
        Marketplaces.update_account_role_priorities(
          marketplace_account,
          ["owner", "role3", "role2", "role1"]
        )

      {:ok,
       [
         %MarketplaceAccountRole{name: "owner", priority: 0},
         %MarketplaceAccountRole{name: "role2", priority: 1},
         %MarketplaceAccountRole{name: "role3", priority: 2},
         %MarketplaceAccountRole{name: "role1", priority: 3}
       ]} =
        Marketplaces.update_account_role_priorities(
          marketplace_account,
          ["owner", "role2", "role3", "role1"]
        )
    end

    test "it should set new role permissions" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      role = Marketplaces.get_account_role(marketplace, "owner")

      {:ok, _} =
        Marketplaces.set_account_role_permissions(
          marketplace_account,
          role,
          [PermissionDefs.marketplaces__marketplace_item__create()]
        )
    end

    test "delete account role" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      role = Marketplaces.get_account_role(marketplace, "owner")

      {:error, _} = Marketplaces.delete_account_role(marketplace_account, role)

      {:ok, role} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role1"})

      {:ok, _} = Marketplaces.delete_account_role(marketplace_account, role)

      refute Enum.any?(
               Marketplaces.all_account_roles(marketplace, deleted_at: false),
               fn role ->
                 role.name == "role1"
               end
             )

      assert Enum.any?(
               Marketplaces.all_account_roles(marketplace, deleted_at: true),
               fn role ->
                 role.name == "role1"
               end
             )

      assert Enum.any?(
               Marketplaces.all_account_roles(marketplace),
               fn role ->
                 role.name == "role1"
               end
             )

      Marketplaces.undo_delete_account_role(marketplace_account, role)

      assert Enum.any?(
               Marketplaces.all_account_roles(marketplace, deleted_at: false),
               fn role ->
                 role.name == "role1"
               end
             )
    end

    test "assign new role" do
      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, role1} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role1"})

      {:ok, target_marketplace_account} =
        Marketplaces.add_account_to_marketplace(
          marketplace_account,
          AccountsFixture.account!(),
          role1
        )

      {:ok, target_marketplace_account} =
        Marketplaces.assign_account_role(
          marketplace_account,
          target_marketplace_account,
          role1
        )

      {:error, _} =
        Marketplaces.assign_account_role(
          target_marketplace_account,
          marketplace_account,
          role1
        )

      {:ok, marketplace_account} =
        Marketplaces.assign_account_role(marketplace_account, role1)

      assert marketplace_account.role_id == role1.id
    end

    test "update a role" do
      updated_name = "test"

      %{role: role, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, role2} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role2"})

      {:error, _} = Marketplaces.update_account_role(marketplace_account, role, %{name: "test"})

      {:ok, updated_role} =
        Marketplaces.update_account_role(marketplace_account, role2, %{name: updated_name})

      assert updated_role.id == role2.id
      assert updated_role.name == updated_name
    end

    test "block and then unblock an account" do
      %{marketplace_account: marketplace_account, marketplace: marketplace} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, role1} =
        Marketplaces.create_account_role(marketplace_account, %{name: "role1"})

      {:ok, target_marketplace_account} =
        Marketplaces.add_account_to_marketplace(
          marketplace_account,
          AccountsFixture.account!(),
          role1
        )

      {:ok, target_marketplace_account} =
        Marketplaces.block_account(marketplace_account, target_marketplace_account)

      {:error, _} =
        Marketplaces.block_account(marketplace_account, target_marketplace_account)

      assert Enum.any?(
               Marketplaces.all_accounts(marketplace),
               fn account ->
                 account.id == target_marketplace_account.id
               end
             )

      assert Enum.any?(
               Marketplaces.all_accounts(marketplace, blocked_at: true),
               fn account ->
                 account.id == target_marketplace_account.id
               end
             )

      refute Enum.any?(
               Marketplaces.all_accounts(marketplace, blocked_at: false),
               fn account ->
                 account.id == target_marketplace_account.id
               end
             )

      {:ok, target_marketplace_account} =
        Marketplaces.undo_block_account(marketplace_account, target_marketplace_account)

      {:error, _} =
        Marketplaces.undo_block_account(marketplace_account, target_marketplace_account)

      assert Enum.any?(
               Marketplaces.all_accounts(marketplace),
               fn account ->
                 account.id == target_marketplace_account.id
               end
             )

      refute Enum.any?(
               Marketplaces.all_accounts(marketplace, blocked_at: true),
               fn account ->
                 account.id == target_marketplace_account.id
               end
             )

      assert Enum.any?(
               Marketplaces.all_accounts(marketplace, blocked_at: false),
               fn account ->
                 account.id == target_marketplace_account.id
               end
             )
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
