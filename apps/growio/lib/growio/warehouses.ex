defmodule Growio.Warehouses do
  import Ecto.Query
  import Growio.Permissions.PermissionDefs
  alias Ecto.Changeset
  alias Growio.Repo
  alias Growio.Permissions
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Warehouses.Warehouse
  alias Growio.Warehouses.WarehouseItem

  def all_warehouses(%MarketplaceAccount{} = initiator) do
    with true <- Permissions.ok?(initiator, warehouses__warehouse__read()),
         initiator = Repo.preload(initiator, [:marketplace]) do
      all_warehouses(initiator.marketplace)
    else
      _ -> {:error, "cannot get all warehouses"}
    end
  end

  def all_warehouses(%Marketplace{} = marketplace) do
    Warehouse
    |> where([warehouse], warehouse.marketplace_id == ^marketplace.id)
    |> Repo.all()
  end

  def get_warehouse(%MarketplaceAccount{} = initiator, id) when is_integer(id) do
    with true <- Permissions.ok?(initiator, warehouses__warehouse__read()),
         warehouse = %Warehouse{} <- get_warehouse(id),
         true <- Permissions.ok?(initiator, warehouse) do
      warehouse
    else
      _ -> {:error, "cannot get all warehouses"}
    end
  end

  def get_warehouse(id) when is_integer(id) do
    Repo.get(Warehouse, id)
  end

  def create_warehouse(%MarketplaceAccount{} = initiator, %{} = params) do
    with true <- Permissions.ok?(initiator, warehouses__warehouse__create()),
         initiator = Repo.preload(initiator, [:marketplace]) do
      create_warehouse(initiator.marketplace, params)
    end
  end

  def create_warehouse(%Marketplace{} = marketplace, %{} = params) do
    Warehouse.changeset(params)
    |> Changeset.put_assoc(:marketplace, marketplace)
    |> Repo.insert()
  end

  def update_warehouse(%MarketplaceAccount{} = initiator, %Warehouse{} = warehouse, %{} = params) do
    with true <- Permissions.ok?(initiator, warehouse, warehouses__warehouse__update()) do
      update_warehouse(warehouse, params)
    end
  end

  def update_warehouse(%Warehouse{} = warehouse, %{} = params) do
    Warehouse.changeset(warehouse, params)
    |> Repo.update()
  end

  def all_warehouse_items(%MarketplaceAccount{} = initiator, %Warehouse{} = warehouse) do
    with true <- Permissions.ok?(initiator, warehouse, warehouses__warehouse__read()) do
      all_warehouse_items(warehouse)
    end
  end

  def all_warehouse_items(%Warehouse{} = warehouse) do
    WarehouseItem
    |> where([item], item.warehouse_id == ^warehouse.id)
    |> preload([:marketplace_item])
    |> Repo.all()
  end

  def create_warehouse_item(
        %MarketplaceAccount{} = initiator,
        %Warehouse{} = warehouse,
        %MarketplaceItem{} = marketplace_item,
        %{} = params
      ) do
    with true <- Permissions.ok?(initiator, warehouse, warehouses__warehouse_item__create()),
         true <- Permissions.ok?(initiator, marketplace_item) do
      create_warehouse_item(warehouse, marketplace_item, params)
    end
  end

  def create_warehouse_item(
        %Warehouse{} = warehouse,
        %MarketplaceItem{} = marketplace_item,
        %{} = params
      ) do
    with changeset = %Changeset{valid?: true} <- WarehouseItem.changeset(params),
         marketplace_item = Repo.preload(marketplace_item, [:category]),
         true <- warehouse.marketplace_id == marketplace_item.category.marketplace_id,
         false <-
           Repo.exists?(
             WarehouseItem
             |> where([item], item.marketplace_item_id == ^marketplace_item.id)
             |> where([item], item.warehouse_id == ^warehouse.id)
           ) do
      changeset
      |> Changeset.put_assoc(:warehouse, warehouse)
      |> Changeset.put_assoc(:marketplace_item, marketplace_item)
      |> Repo.insert()
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot create a warehouse item"}
    end
  end

  def update_warehouse_item(
        %MarketplaceAccount{} = initiator,
        %WarehouseItem{} = item,
        %{} = params
      ) do
    with true <- Permissions.ok?(initiator, item, warehouses__warehouse_item__update()) do
      update_warehouse_item(item, params)
    end
  end

  def update_warehouse_item(%WarehouseItem{} = item, %{} = params) do
    WarehouseItem.changeset(item, params)
    |> Repo.update()
  end
end
