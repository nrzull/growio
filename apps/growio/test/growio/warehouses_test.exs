defmodule Growio.WarehousesTest do
  use Growio.DataCase
  alias Growio.AccountsFixture
  alias Growio.MarketplacesFixture
  alias Growio.WarehousesFixture
  alias Growio.Warehouses
  alias Growio.Warehouses.Warehouse
  alias Growio.Warehouses.WarehouseItem

  describe "Growio.Warehouses" do
    test "create a warehouse" do
      valid_name = "warehouse"

      %{marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      {:ok, %Warehouse{} = warehouse} =
        Warehouses.create_warehouse(marketplace_account, %{name: valid_name})

      assert warehouse.name == valid_name
    end

    test "get all warehouses" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      WarehousesFixture.warehouse!(marketplace)
      WarehousesFixture.warehouse!(marketplace)

      [%Warehouse{}, %Warehouse{}] = Warehouses.all_warehouses(marketplace_account)
    end

    test "update a warehouse" do
      updated_name = "updated name"

      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      warehouse = WarehousesFixture.warehouse!(marketplace)

      {:ok, warehouse} =
        Warehouses.update_warehouse(marketplace_account, warehouse, %{name: updated_name})

      assert warehouse.name == updated_name
    end

    test "create a warehouse item" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      warehouse = WarehousesFixture.warehouse!(marketplace)
      category = MarketplacesFixture.item_category!(marketplace)
      %{item: item} = MarketplacesFixture.item!(category)

      {:ok, %WarehouseItem{}} =
        Warehouses.create_warehouse_item(marketplace_account, warehouse, item, %{
          quantity: 1,
          infinity: true
        })
    end

    test "all warehouse items" do
      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      warehouse = WarehousesFixture.warehouse!(marketplace)
      category = MarketplacesFixture.item_category!(marketplace)
      %{item: item1} = MarketplacesFixture.item!(category)
      %{item: item2} = MarketplacesFixture.item!(category)

      {:ok, warehouse_item1} =
        Warehouses.create_warehouse_item(marketplace_account, warehouse, item1, %{
          quantity: 1,
          infinity: true
        })

      {:ok, warehouse_item2} =
        Warehouses.create_warehouse_item(marketplace_account, warehouse, item2, %{
          quantity: 1,
          infinity: true
        })

      [%WarehouseItem{id: warehouse_item1_id}, %WarehouseItem{id: warehouse_item2_id}] =
        Warehouses.all_warehouse_items(marketplace_account, warehouse)

      assert warehouse_item1.id == warehouse_item1_id
      assert warehouse_item2.id == warehouse_item2_id
    end

    test "update warehouse item" do
      updated_params = %{infinity: false, quantity: 2}

      %{marketplace: marketplace, marketplace_account: marketplace_account} =
        MarketplacesFixture.marketplace!(AccountsFixture.account!())

      warehouse = WarehousesFixture.warehouse!(marketplace)
      category = MarketplacesFixture.item_category!(marketplace)
      %{item: item1} = MarketplacesFixture.item!(category)

      {:ok, warehouse_item} =
        Warehouses.create_warehouse_item(marketplace_account, warehouse, item1, %{
          quantity: 1,
          infinity: true
        })

      {:ok, warehouse_item} =
        Warehouses.update_warehouse_item(marketplace_account, warehouse_item, updated_params)

      assert warehouse_item.infinity == updated_params.infinity
      assert warehouse_item.quantity == updated_params.quantity
    end
  end
end
