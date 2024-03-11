defmodule Growio.Warehouses do
  import Ecto.Query
  alias Ecto.Changeset
  alias Growio.Repo
  alias Growio.Warehouses.Warehouse
  alias Growio.Warehouses.WarehouseItem
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceItem

  def all_warehouses(%Marketplace{} = marketplace) do
    Warehouse
    |> where([warehouse], warehouse.marketplace_id == ^marketplace.id)
    |> Repo.all()
  end

  def get_warehouse(id) when is_integer(id) do
    Repo.get(Warehouse, id)
  end

  def create_warehouse(%Marketplace{} = marketplace, %{} = params) do
    Warehouse.changeset(params)
    |> Changeset.put_assoc(:marketplace, marketplace)
    |> Repo.insert()
  end

  def update_warehouse(%Warehouse{} = warehouse, %{} = params) do
    Warehouse.changeset(warehouse, params)
    |> Repo.update()
  end

  def all_warehouse_items(%Warehouse{} = warehouse) do
    WarehouseItem
    |> where([item], item.warehouse_id == ^warehouse.id)
    |> preload([:marketplace_item])
    |> Repo.all()
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

  def update_warehouse_item(%WarehouseItem{} = item, %{} = params) do
    WarehouseItem.changeset(item, params)
    |> Repo.update()
  end
end