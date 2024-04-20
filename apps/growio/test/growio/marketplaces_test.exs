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
  alias Growio.Marketplaces.MarketplaceItemAsset
  alias Growio.Marketplaces.MarketplaceAccountEmailInvitation
  alias Growio.Marketplaces.MarketplaceMarket
  alias Growio.Marketplaces.MarketplaceMarketItem
  alias Growio.Permissions.Permission

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
      marketplace_name = "marketplace name"

      {:ok, %{marketplace: marketplace, marketplace_account: marketplace_account}} =
        Marketplaces.create_marketplace(account, %{name: marketplace_name})

      assert marketplace.name == marketplace_name
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

    test "get all account roles" do
      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      match?([_ | _], Marketplaces.all_account_roles(marketplace_account))
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

      {:ok, role} =
        Marketplaces.update_account_role(marketplace_account, role, %{name: "test", priority: 9})

      assert role.priority == 0
      assert role.name == "test"

      new_permission = PermissionDefs.marketplaces__market__create()

      {:ok, updated_role} =
        Marketplaces.update_account_role(marketplace_account, role2, %{
          "name" => updated_name,
          "permissions" => [new_permission]
        })

      updated_role = Repo.preload(updated_role, [:permissions])

      match?([%Permission{name: ^new_permission}], updated_role.permissions)
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

      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, %MarketplaceItemCategory{marketplace_id: marketplace_id, name: name}} =
        Marketplaces.create_item_category(marketplace_account, %{name: valid_name})

      assert marketplace_account.marketplace_id == marketplace_id
      assert valid_name == name
    end

    test "delete item categories" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, _} = Marketplaces.delete_item_category(marketplace_account, c1)
    end

    test "update item categories" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, updated_c1} =
        Marketplaces.update_item_category(marketplace_account, c1, %{name: "other name"})

      assert c1.id == updated_c1.id
      refute c1.name == updated_c1.name
    end

    test "get all item categories" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)
      c2 = MarketplacesFixture.item_category!(marketplace)

      [%MarketplaceItemCategory{id: c1_id}, %MarketplaceItemCategory{id: c2_id}] =
        Marketplaces.all_item_categories(marketplace_account)

      assert c1.id == c1_id
      assert c2.id == c2_id
    end

    test "get item tree" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      root = MarketplacesFixture.item_category!(marketplace)
      root_id = Map.get(root, :id)

      root_child = MarketplacesFixture.item_category!(marketplace, %{parent_id: root.id})
      root_child_id = Map.get(root_child, :id)

      root_child_child =
        MarketplacesFixture.item_category!(marketplace, %{parent_id: root_child.id})

      root_item = MarketplacesFixture.item!(root)
      root_item_id = Map.get(root_item, :id)
      MarketplacesFixture.item!(root_child)
      MarketplacesFixture.item!(root_child_child)

      [
        %{
          id: ^root_id,
          children: [%{id: ^root_child_id, children: [_ | _]}, %{id: ^root_item_id}]
        }
        | _
      ] =
        Marketplaces.all_items_tree(marketplace_account, deleted_at: false)

      [] = Marketplaces.all_items_tree(marketplace_account, deleted_at: true)
    end

    test "create an item" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)
      c2 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %MarketplaceItem{} = item1} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item1"})

      {:ok, %MarketplaceItem{}} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item2", origin_id: item1.id})

      {:ok, %MarketplaceItem{}} =
        Marketplaces.create_item(marketplace_account, c2, %{name: "name3", origin_id: item1.id})
    end

    test "update an item" do
      updated_name = "item11"

      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %MarketplaceItem{} = item1} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item1"})

      {:ok, updated_item} =
        Marketplaces.update_item(marketplace_account, item1, %{name: updated_name})

      assert updated_item.name == updated_name
    end

    test "delete an item" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %MarketplaceItem{} = item1} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item1"})

      {:ok, %MarketplaceItem{deleted_at: deleted_at}} =
        Marketplaces.delete_item(marketplace_account, item1)

      refute is_nil(deleted_at)
    end

    test "create an item asset" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      %{marketplace_account: other_marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %MarketplaceItem{} = item1} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item1"})

      {:ok, %MarketplaceItemAsset{}} =
        Marketplaces.create_item_asset(marketplace_account, item1, %{
          src: "src",
          mimetype: "mimetype"
        })

      {:error, _} =
        Marketplaces.create_item_asset(other_marketplace_account, item1, %{
          src: "src",
          mimetype: "mimetype"
        })
    end

    test "all item assets" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %MarketplaceItem{} = item1} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item1"})

      {:ok, _} =
        Marketplaces.create_item_asset(marketplace_account, item1, %{
          src: "src",
          mimetype: "mimetype"
        })

      {:ok, _} =
        Marketplaces.create_item_asset(marketplace_account, item1, %{
          src: "src",
          mimetype: "mimetype"
        })

      [_, _] = Marketplaces.all_item_assets(marketplace_account, item1)
    end

    test "get an item asset" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %MarketplaceItem{} = item1} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item1"})

      {:ok, asset} =
        Marketplaces.create_item_asset(marketplace_account, item1, %{
          src: "src",
          mimetype: "mimetype"
        })

      fetched_asset =
        Marketplaces.get_item_asset(marketplace_account, item1, asset.id)

      assert asset.id == fetched_asset.id
    end

    test "update an item asset" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %MarketplaceItem{} = item1} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item1"})

      {:ok, asset} =
        Marketplaces.create_item_asset(marketplace_account, item1, %{
          src: "src",
          mimetype: "mimetype"
        })

      {:ok, updated_asset} =
        Marketplaces.update_item_asset(marketplace_account, asset, %{
          src: "src2",
          mimetype: "mimetype2"
        })

      assert updated_asset.src == "src2"
      assert updated_asset.mimetype == "mimetype2"
    end

    test "delete an item asset" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      c1 = MarketplacesFixture.item_category!(marketplace)

      {:ok, %MarketplaceItem{} = item1} =
        Marketplaces.create_item(marketplace_account, c1, %{name: "item1"})

      {:ok, asset} =
        Marketplaces.create_item_asset(marketplace_account, item1, %{
          src: "src",
          mimetype: "mimetype"
        })

      {:ok, deleted_asset} = Marketplaces.delete_item_asset(marketplace_account, asset)

      assert asset.id == deleted_asset.id
    end

    test "get all email invitations" do
      email = "hello@example.com"

      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      role = MarketplacesFixture.role!(marketplace)

      Marketplaces.create_account_email_invitation(marketplace_account, role, %{
        email: email
      })

      match?(
        [%MarketplaceAccountEmailInvitation{email: ^email}],
        Marketplaces.all_account_email_invitations(marketplace_account)
      )
    end

    test "create an account email invitation" do
      email = "hello@example.com"

      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      role = MarketplacesFixture.role!(marketplace)

      Marketplaces.create_account_email_invitation(marketplace_account, role, %{
        email: email
      })

      %MarketplaceAccountEmailInvitation{id: id1, email: fetched_email} =
        Marketplaces.get_account_email_invitation(:email, email)

      assert email == fetched_email

      Marketplaces.create_account_email_invitation(marketplace_account, role, %{
        email: email
      })

      %MarketplaceAccountEmailInvitation{id: id2} =
        Marketplaces.get_account_email_invitation(:email, email)

      refute id1 == id2
    end

    test "use an account email invitation" do
      email = "hello@example.com"

      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      role = MarketplacesFixture.role!(marketplace)

      {:ok, %MarketplaceAccountEmailInvitation{password: password}} =
        Marketplaces.create_account_email_invitation(marketplace_account, role, %{
          email: email
        })

      {:ok, %{marketplace_account: _}} =
        Marketplaces.use_account_email_invitation(password)

      nil = Marketplaces.get_account_email_invitation(:email, email)
    end

    test "create a market" do
      valid_address = "valid_address"

      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, %MarketplaceMarket{} = market} =
        Marketplaces.create_market(marketplace_account, %{address: valid_address})

      assert market.address == valid_address
    end

    test "get all markets" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      MarketplacesFixture.market!(marketplace)
      MarketplacesFixture.market!(marketplace)

      [%MarketplaceMarket{}, %MarketplaceMarket{}] =
        Marketplaces.all_markets(marketplace_account)
    end

    test "update a market" do
      updated_address = "updated_address"

      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      market = MarketplacesFixture.market!(marketplace)

      {:ok, market} =
        Marketplaces.update_market(marketplace_account, market, %{address: updated_address})

      assert market.address == updated_address
    end

    test "create a market item" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      market = MarketplacesFixture.market!(marketplace)
      category = MarketplacesFixture.item_category!(marketplace)
      item = MarketplacesFixture.item!(category)

      {:ok, %MarketplaceMarketItem{}} =
        Marketplaces.create_market_item(marketplace_account, market, item, %{
          quantity: 1,
          infinity: true
        })
    end

    test "all market items" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      market = MarketplacesFixture.market!(marketplace)
      category = MarketplacesFixture.item_category!(marketplace)
      item1 = MarketplacesFixture.item!(category)
      item2 = MarketplacesFixture.item!(category)

      {:ok, market_item1} =
        Marketplaces.create_market_item(marketplace_account, market, item1, %{
          quantity: 1,
          infinity: true
        })

      {:ok, market_item2} =
        Marketplaces.create_market_item(marketplace_account, market, item2, %{
          quantity: 1,
          infinity: true
        })

      [
        %MarketplaceMarketItem{id: market_item1_id},
        %MarketplaceMarketItem{id: market_item2_id}
      ] =
        Marketplaces.all_market_items(marketplace_account, market)

      assert market_item1.id == market_item1_id
      assert market_item2.id == market_item2_id
    end

    test "update market item" do
      updated_params = %{infinity: false, quantity: 2}

      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      market = MarketplacesFixture.market!(marketplace)
      category = MarketplacesFixture.item_category!(marketplace)
      item1 = MarketplacesFixture.item!(category)

      {:ok, market_item} =
        Marketplaces.create_market_item(marketplace_account, market, item1, %{
          quantity: 1,
          infinity: true
        })

      {:ok, market_item} =
        Marketplaces.update_market_item(marketplace_account, market_item, updated_params)

      assert market_item.infinity == updated_params.infinity
      assert market_item.quantity == updated_params.quantity
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
