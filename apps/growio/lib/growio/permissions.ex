defmodule Growio.Permissions do
  alias Growio.Cache
  alias Growio.Repo
  alias Growio.Permissions.Permission
  alias Growio.Permissions.PermissionDefs
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Warehouses.Warehouse
  alias Growio.Warehouses.WarehouseItem

  @all_cache_ttl :timer.minutes(10)

  def definitions do
    PermissionDefs.__info__(:functions)
    |> Enum.map(fn {name, _} ->
      apply(PermissionDefs, name, [])
    end)
  end

  def all(opts \\ []) do
    repo = Keyword.get(opts, :repo, Repo)

    case Cache.get("Growio.Permissions.all") do
      values when is_list(values) ->
        values

      _ ->
        values =
          Enum.map(definitions(), fn name ->
            repo.get_by(Permission, name: name)
          end)

        Cache.put("Growio.Permissions.all", values, ttl: @all_cache_ttl)

        values
    end
  end

  def ok?(%MarketplaceAccount{} = initiator, %Warehouse{} = warehouse) do
    initiator.marketplace_id === warehouse.marketplace_id
  end

  def ok?(%MarketplaceAccount{} = initiator, %MarketplaceItem{} = item) do
    with item = Repo.preload(item, [:category]),
         true <- initiator.marketplace_id === item.category.marketplace_id do
      true
    end
  end

  def ok?(%MarketplaceAccount{} = initiator, %WarehouseItem{} = item) do
    with item = Repo.preload(item, [:warehouse]),
         true <- initiator.marketplace_id === item.warehouse.marketplace_id do
      true
    end
  end

  def ok?(%MarketplaceAccount{} = initiator, %MarketplaceAccountRole{} = role) do
    with true <- initiator.marketplace_id === role.marketplace_id,
         initiator = Repo.preload(initiator, [:role]),
         true <- initiator.role.priority <= role.priority do
      true
    end
  end

  def ok?(%MarketplaceAccount{} = initiator, %MarketplaceAccount{} = account) do
    with true <- initiator.marketplace_id === account.marketplace_id,
         initiator = Repo.preload(initiator, [:role]),
         account = Repo.preload(account, [:role]),
         true <- initiator.role.priority < account.role.priority do
      true
    end
  end

  def ok?(%MarketplaceAccount{} = initiator, %MarketplaceItemCategory{} = category) do
    initiator.marketplace_id === category.marketplace_id
  end

  def ok?(%MarketplaceAccount{} = initiator, permission) when is_bitstring(permission) do
    with initiator = Repo.preload(initiator, role: [:permissions]),
         true <-
           Enum.any?(initiator.role.permissions, fn p ->
             p.name === permission
           end) do
      true
    end
  end

  def ok?(initiator, target, permission) do
    with true <- ok?(initiator, permission),
         true <- ok?(initiator, target) do
      true
    end
  end
end
