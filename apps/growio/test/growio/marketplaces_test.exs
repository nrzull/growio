defmodule Growio.MarketplacesTest do
  use Growio.DataCase
  alias Growio.AccountsFixture
  alias Growio.Permissions.PermissionDefs
  alias Growio.MarketplacesFixture
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Marketplaces.MarketplaceItemVariant

  @valid_name "marketplace name"

  describe "Growio.Marketplaces" do
    test "get marketplace accounts of a marketplace" do
      account = AccountsFixture.account!()
      account2 = AccountsFixture.account!()

      %{marketplace_account: marketplace_account, marketplace: marketplace} =
        MarketplacesFixture.marketplace!(account)

      role1 = MarketplacesFixture.role!(marketplace)

      Marketplaces.add_account_to_marketplace(
        marketplace_account,
        account2,
        role1
      )

      [%MarketplaceAccount{account_id: account_id}, %MarketplaceAccount{account_id: account2_id}] =
        Marketplaces.all_accounts(marketplace_account)

      assert account.id == account_id
      assert account2.id == account2_id
    end

    test "get marketplace accounts of an account" do
      account = AccountsFixture.account!()

      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(account)

      [%MarketplaceAccount{id: id}] = Marketplaces.all_accounts(account)

      assert marketplace_account.id == id
    end

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

    test "get an account role" do
      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, %MarketplaceAccountRole{}} = Marketplaces.get_account_role(marketplace_account)
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
      %{marketplace_account: marketplace_account, marketplace: marketplace} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      role1 = MarketplacesFixture.role!(marketplace)

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

      role1 = MarketplacesFixture.role!(marketplace)

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

    test "create item categories" do
      valid_name = "category1"

      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, %MarketplaceItemCategory{marketplace_id: marketplace_id, name: name}} =
        Marketplaces.create_item_category(marketplace, %{name: valid_name})

      assert marketplace.id == marketplace_id
      assert valid_name == name
    end

    test "delete item categories" do
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, _} =
        MarketplacesFixture.item_category!(marketplace)
        |> Marketplaces.delete_item_category()
    end

    test "update item categories" do
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, updated_c1} = Marketplaces.update_item_category(c1, %{name: "other name"})

      assert c1.id == updated_c1.id
      refute c1.name == updated_c1.name
    end

    test "get all item categories" do
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)
      c2 = MarketplacesFixture.item_category!(marketplace)

      [%MarketplaceItemCategory{id: c1_id}, %MarketplaceItemCategory{id: c2_id}] =
        Marketplaces.all_item_categories(marketplace)

      assert c1.id == c1_id
      assert c2.id == c2_id
    end

    test "create an item" do
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)
      c2 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %{item: %MarketplaceItem{} = item1}} =
        Marketplaces.create_item(c1, %{name: "item1"})

      {:ok,
       %{
         item: %MarketplaceItem{} = _,
         variant: %MarketplaceItemVariant{} = _
       }} =
        Marketplaces.create_item(c1, %{name: "item2", variant_of: item1.id})

      {:error, _} = Marketplaces.create_item(c2, %{name: "name3", variant_of: item1.id})
    end

    test "update an item" do
      updated_name = "item11"
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, %{item: %MarketplaceItem{} = item1}} =
        MarketplacesFixture.item_category!(marketplace)
        |> Marketplaces.create_item(%{name: "item1"})

      {:ok, updated_item} = Marketplaces.update_item(item1, %{name: updated_name})

      assert updated_item.name == updated_name
    end

    test "delete an item" do
      %{marketplace: marketplace} = MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, %{item: %MarketplaceItem{} = item1}} =
        MarketplacesFixture.item_category!(marketplace)
        |> Marketplaces.create_item(%{name: "item1"})

      {:ok, %MarketplaceItem{deleted_at: deleted_at}} = Marketplaces.delete_item(item1)

      refute is_nil(deleted_at)
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
