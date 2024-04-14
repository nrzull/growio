defmodule Growio.Marketplaces do
  import Ecto.Query
  import Growio.Permissions.PermissionDefs
  alias Ecto.Changeset
  alias Ecto.Multi
  alias Growio.Utils
  alias Growio.Repo
  alias Growio.Accounts
  alias Growio.Accounts.Account
  alias Growio.Permissions
  alias Growio.Subscriptions
  alias Growio.Subscriptions.Subscription
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Marketplaces.MarketplaceAccountRolePermission
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Marketplaces.MarketplaceItemVariant
  alias Growio.Marketplaces.MarketplaceItemAsset
  alias Growio.Marketplaces.MarketplaceAccountEmailInvitation
  alias Growio.Marketplaces.MarketplaceWarehouse
  alias Growio.Marketplaces.MarketplaceWarehouseItem
  alias Growio.Marketplaces.MarketplaceSubscription

  def get_marketplace_by(:id, id) do
    Repo.get(Marketplace, id)
  end

  def create_marketplace(%Account{} = account, %{} = params) do
    marketplace_changeset = Marketplace.changeset(params)
    owner_role_changeset = MarketplaceAccountRole.owner_changeset()

    with %Changeset{valid?: true} <- marketplace_changeset,
         %Changeset{valid?: true} <- owner_role_changeset do
      Multi.new()
      |> Multi.insert(:marketplace, marketplace_changeset)
      |> Multi.insert(:role, fn %{marketplace: marketplace} ->
        Changeset.put_assoc(owner_role_changeset, :marketplace, marketplace)
      end)
      |> Multi.run(:permissions, fn repo, %{} ->
        {:ok, Permissions.all(repo: repo)}
      end)
      |> Multi.insert_all(
        :insert_all,
        MarketplaceAccountRolePermission,
        fn %{role: role, permissions: permissions} ->
          Enum.map(permissions, fn permission ->
            %{
              role_id: role.id,
              permission_id: permission.id,
              inserted_at: Utils.naive_utc_now(),
              updated_at: Utils.naive_utc_now()
            }
          end)
        end
      )
      |> Multi.run(:marketplace_account, fn repo, %{marketplace: marketplace, role: role} ->
        add_account_to_marketplace(account, marketplace, role, repo: repo)
      end)
      |> Multi.run(:subscription, fn repo, %{marketplace: marketplace} ->
        create_subscription(
          marketplace,
          Subscriptions.get_default_subscription(),
          %{
            expired_at:
              Utils.naive_utc_now()
              |> NaiveDateTime.add(365, :day)
              |> NaiveDateTime.truncate(:second)
          },
          repo: repo
        )
      end)
      |> Repo.transaction()
    end
  end

  def update_marketplace(%MarketplaceAccount{} = initiator, %{} = params) do
    with true <- Permissions.ok?(initiator, marketplaces__marketplace__update()) do
      %MarketplaceAccount{marketplace: marketplace} = Repo.preload(initiator, [:marketplace])

      update_marketplace(marketplace, params)
    else
      _ -> {:error, "cannot update a marketplace"}
    end
  end

  def update_marketplace(%Marketplace{} = marketplace, %{} = params) do
    Marketplace.changeset(marketplace, params)
    |> Repo.update()
  end

  def all_accounts(initiator, opts \\ [])

  def all_accounts(%Account{} = initiator, opts) do
    MarketplaceAccount
    |> where([account], account.account_id == ^initiator.id)
    |> then(fn query ->
      case Keyword.get(opts, :blocked_at) do
        true ->
          where(query, [account], not is_nil(account.blocked_at))

        false ->
          where(query, [account], is_nil(account.blocked_at))

        _ ->
          query
      end
    end)
    |> Repo.all()
  end

  def all_accounts(%MarketplaceAccount{} = initiator, opts) do
    Map.get(Repo.preload(initiator, [:marketplace]), :marketplace)
    |> all_accounts(opts)
  end

  def all_accounts(%Marketplace{} = marketplace, opts) do
    MarketplaceAccount
    |> where([account], account.marketplace_id == ^marketplace.id)
    |> then(fn query ->
      case Keyword.get(opts, :blocked_at) do
        true ->
          where(query, [account], not is_nil(account.blocked_at))

        false ->
          where(query, [account], is_nil(account.blocked_at))

        _ ->
          query
      end
    end)
    |> Repo.all()
  end

  def add_account_to_marketplace(
        %MarketplaceAccount{} = initiator,
        %Account{} = account,
        %MarketplaceAccountRole{} = role
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             marketplaces__marketplace_account__create()
           ),
         initiator = Repo.preload(initiator, [:role, :marketplace]),
         true <- initiator.role.priority < role.priority do
      add_account_to_marketplace(account, initiator.marketplace, role)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot add an account to marketplace"}
    end
  end

  def add_account_to_marketplace(
        %Account{} = account,
        %Marketplace{} = marketplace,
        %MarketplaceAccountRole{} = role,
        opts \\ []
      ) do
    repo = Keyword.get(opts, :repo, Repo)

    %MarketplaceAccount{}
    |> Changeset.change()
    |> Changeset.put_assoc(:account, account)
    |> Changeset.put_assoc(:marketplace, marketplace)
    |> Changeset.put_assoc(:role, role)
    |> repo.insert()
  end

  def block_account(%MarketplaceAccount{} = initiator, %MarketplaceAccount{} = account) do
    with true <- initiator.marketplace_id === account.marketplace_id,
         true <-
           Permissions.ok?(
             initiator,
             account,
             marketplaces__marketplace_account__delete()
           ),
         false <- blocked_account?(account) do
      block_account(account)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot block an account"}
    end
  end

  def block_account(%MarketplaceAccount{} = account) do
    account
    |> Changeset.change()
    |> Changeset.put_change(:blocked_at, Utils.naive_utc_now())
    |> Repo.update()
  end

  def undo_block_account(%MarketplaceAccount{} = initiator, %MarketplaceAccount{} = account) do
    with true <-
           Permissions.ok?(
             initiator,
             account,
             marketplaces__marketplace_account__delete()
           ),
         true <- blocked_account?(account) do
      undo_block_account(account)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot unblock an account"}
    end
  end

  def undo_block_account(%MarketplaceAccount{} = account) do
    account
    |> Changeset.change()
    |> Changeset.force_change(:blocked_at, nil)
    |> Repo.update()
  end

  def blocked_account?(%MarketplaceAccount{} = account) do
    not is_nil(account.blocked_at)
  end

  def get_account(%MarketplaceAccount{} = initiator, id) when is_integer(id) do
    MarketplaceAccount
    |> where([account], account.id == ^id)
    |> where([account], account.marketplace_id == ^initiator.marketplace_id)
    |> Repo.one()
  end

  def get_account(%Marketplace{} = marketplace, id) when is_integer(id) do
    MarketplaceAccount
    |> where([account], account.id == ^id)
    |> where([account], account.marketplace_id == ^marketplace.id)
    |> Repo.one()
  end

  def get_account(%Account{} = initiator, id) when is_integer(id) do
    MarketplaceAccount
    |> where([account], account.id == ^id)
    |> where([account], account.account_id == ^initiator.id)
    |> Repo.one()
  end

  def update_account(
        %MarketplaceAccount{} = initiator,
        %MarketplaceAccount{} = target,
        %{} = params
      ) do
    with true <- Permissions.ok?(initiator, target, marketplaces__marketplace_account__update()) do
      update_account(target, params)
    else
      _ -> {:error, "cannot update a user"}
    end
  end

  def update_account(%MarketplaceAccount{} = account, %{} = params) do
    MarketplaceAccount.update_changeset(account, params)
    |> Repo.update()
  end

  def get_account_role(%MarketplaceAccount{} = initiator) do
    {:ok, Map.get(Repo.preload(initiator, role: [:permissions]), :role)}
  end

  def get_account_role(role_id) when is_integer(role_id) do
    MarketplaceAccountRole
    |> where([role], role.id == ^role_id)
    |> preload([role], [:permissions])
    |> Repo.one()
  end

  def get_account_role(%MarketplaceAccount{} = initiator, id) when is_integer(id) do
    MarketplaceAccountRole
    |> where([role], role.id == ^id)
    |> where([role], role.marketplace_id == ^initiator.marketplace_id)
    |> preload([role], [:permissions])
    |> Repo.one()
  end

  def get_account_role(%Marketplace{} = marketplace, name) when is_bitstring(name) do
    MarketplaceAccountRole
    |> where([role], role.name == ^name)
    |> where([role], role.marketplace_id == ^marketplace.id)
    |> preload([role], [:permissions])
    |> Repo.one()
  end

  def create_account_role(%MarketplaceAccount{} = initiator, %{} = params) do
    with true <-
           Permissions.ok?(
             initiator,
             marketplaces__marketplace_account_role__create()
           ),
         initiator = Repo.preload(initiator, [:marketplace]) do
      create_account_role(initiator.marketplace, params)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot create an account role"}
    end
  end

  def create_account_role(%Marketplace{} = marketplace, %{} = params) do
    with changeset = %Changeset{valid?: true} <- MarketplaceAccountRole.changeset(params),
         {:ok, role} <-
           changeset
           |> Changeset.put_assoc(:marketplace, marketplace)
           |> Changeset.put_change(:priority, length(all_account_roles(marketplace)) + 1)
           |> Repo.insert() do
      if is_list(params["permissions"]) do
        set_account_role_permissions(role, params["permissions"])
      else
        {:ok, role}
      end
    end
  end

  def all_account_roles(initiator, opts \\ [])

  def all_account_roles(%MarketplaceAccount{} = initiator, opts) do
    with true <- Permissions.ok?(initiator, marketplaces__marketplace_account_role__read()) do
      all_account_roles(%Marketplace{id: initiator.marketplace_id}, opts)
    else
      _ -> {:error, "cannot get account roles"}
    end
  end

  def all_account_roles(%Marketplace{} = marketplace, opts) do
    MarketplaceAccountRole
    |> where([role], role.marketplace_id == ^marketplace.id)
    |> order_by(asc: :priority)
    |> then(fn query ->
      case Keyword.get(opts, :permissions) do
        true ->
          preload(query, [:permissions])

        _ ->
          query
      end
    end)
    |> then(fn query ->
      case Keyword.get(opts, :deleted_at) do
        true ->
          where(query, [role], not is_nil(role.deleted_at))

        false ->
          where(query, [role], is_nil(role.deleted_at))

        _ ->
          query
      end
    end)
    |> preload([role], [:permissions])
    |> Repo.all()
  end

  def primary_account_role?(%MarketplaceAccountRole{} = role) do
    role.priority === 0
  end

  def assign_account_role(
        %MarketplaceAccount{} = initiator,
        %MarketplaceAccount{} = account,
        %MarketplaceAccountRole{} = role
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             role,
             marketplaces__marketplace_account_role__create()
           ),
         true <-
           Permissions.ok?(
             initiator,
             account,
             marketplaces__marketplace_account_role__create()
           ) do
      assign_account_role(account, role)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot assign an account role"}
    end
  end

  def assign_account_role(
        %MarketplaceAccount{} = account,
        %MarketplaceAccountRole{} = role
      ) do
    account
    |> Changeset.change()
    |> Changeset.put_change(:role_id, role.id)
    |> Repo.update()
  end

  def update_account_role(
        %MarketplaceAccount{} = initiator,
        %MarketplaceAccountRole{} = role,
        %{} = params
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             role,
             marketplaces__marketplace_account_role__update()
           ) do
      update_account_role(role, params)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot update an account role"}
    end
  end

  def update_account_role(%MarketplaceAccountRole{} = role, %{} = params) do
    MarketplaceAccountRole.changeset(role, params)
    |> then(fn changeset ->
      if primary_account_role?(role),
        do: changeset |> Changeset.put_change(:priority, role.priority),
        else: changeset
    end)
    |> Repo.update()
    |> case do
      {:ok, updated_role} ->
        if is_list(params["permissions"]) do
          set_account_role_permissions(role, params["permissions"])
        else
          {:ok, updated_role}
        end

      err ->
        err
    end
  end

  def delete_account_role(%MarketplaceAccount{} = initiator, %MarketplaceAccountRole{} = role) do
    with true <-
           Permissions.ok?(
             initiator,
             role,
             marketplaces__marketplace_account_role__delete()
           ) do
      delete_account_role(role)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot delete an account role"}
    end
  end

  def delete_account_role(%MarketplaceAccountRole{} = role) do
    cond do
      primary_account_role?(role) ->
        {:error, "cannot delete primary role"}

      Repo.exists?(where(MarketplaceAccount, [acc], acc.role_id == ^role.id)) ->
        {:error, "there is accounts that use current role"}

      not is_nil(role.deleted_at) ->
        {:error, "the role is already deleted"}

      true ->
        update_account_role(role, %{deleted_at: Utils.naive_utc_now()})
    end
  end

  def undo_delete_account_role(
        %MarketplaceAccount{} = initiator,
        %MarketplaceAccountRole{} = role
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             role,
             marketplaces__marketplace_account_role__delete()
           ) do
      undo_delete_account_role(role)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot undo an account role deletion"}
    end
  end

  def undo_delete_account_role(%MarketplaceAccountRole{} = role) do
    role
    |> Changeset.change()
    |> Changeset.force_change(:deleted_at, nil)
    |> Repo.update()
  end

  def set_account_role_permissions(
        %MarketplaceAccount{} = initiator,
        %MarketplaceAccountRole{} = role,
        permission_names
      )
      when is_list(permission_names) do
    with true <-
           Permissions.ok?(
             initiator,
             role,
             marketplaces__marketplace_account_role__update()
           ) do
      set_account_role_permissions(role, permission_names)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot set account role permissions"}
    end
  end

  def set_account_role_permissions(
        %MarketplaceAccountRole{} = role,
        permission_names
      )
      when is_list(permission_names) do
    all_permissions = Permissions.all()

    is_valid_permissions =
      case permission_names do
        [] ->
          true

        _ ->
          Enum.all?(permission_names, fn name ->
            Enum.any?(all_permissions, fn permission -> permission.name == name end)
          end)
      end

    with true <- is_valid_permissions do
      role = Repo.preload(role, [:permissions])

      role_permissions =
        Enum.map(role.permissions, fn permission ->
          Repo.one(
            from(role_permission in MarketplaceAccountRolePermission,
              where:
                role_permission.role_id == ^role.id and
                  role_permission.permission_id == ^permission.id
            )
          )
        end)

      {:ok, _} =
        Multi.new()
        |> Multi.run(:delete_all, fn repo, %{} ->
          {:ok,
           Enum.map(role_permissions, fn role_permission -> repo.delete!(role_permission) end)}
        end)
        |> Multi.insert_all(
          :insert_all,
          MarketplaceAccountRolePermission,
          fn %{} ->
            Enum.map(permission_names, fn name ->
              permission = Enum.find(all_permissions, fn p -> p.name == name end)

              %{
                role_id: role.id,
                permission_id: permission.id,
                inserted_at: Utils.naive_utc_now(),
                updated_at: Utils.naive_utc_now()
              }
            end)
          end
        )
        |> Repo.transaction()

      {:ok, get_account_role(role.id)}
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot set account role permissions"}
    end
  end

  def update_account_role_priorities(
        %MarketplaceAccount{} = initiator,
        [role_name | _] = role_names
      )
      when is_bitstring(role_name) do
    with true <-
           Permissions.ok?(
             initiator,
             marketplaces__marketplace_account_role__update()
           ),
         initiator = Repo.preload(initiator, [:marketplace]) do
      update_account_role_priorities(initiator.marketplace, role_names)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot update account role priorities"}
    end
  end

  def update_account_role_priorities(%Marketplace{} = marketplace, [_ | _] = role_names) do
    all = all_account_roles(marketplace)

    all_names =
      all
      |> Enum.map(fn role -> role.name end)
      |> Enum.sort()

    with true <- all_names === Enum.sort(role_names),
         roles =
           Enum.map(role_names, &Repo.get_by(MarketplaceAccountRole, name: &1)),
         %MarketplaceAccountRole{priority: 0} <- List.first(roles) do
      changesets =
        roles
        |> Enum.with_index()
        |> Enum.map(fn {element, index} ->
          element
          |> Changeset.change()
          |> Changeset.put_change(:priority, index)
        end)

      {:ok, %{update_all: result}} =
        Multi.new()
        |> Multi.run(:update_all, fn repo, %{} ->
          {:ok, Enum.map(changesets, fn changeset -> repo.update!(changeset) end)}
        end)
        |> Repo.transaction()

      {:ok, result}
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot update account role priorities"}
    end
  end

  def all_item_categories(initiator, opts \\ [])

  def all_item_categories(%MarketplaceAccount{} = initiator, opts) do
    with true <-
           Permissions.ok?(
             initiator,
             marketplaces__marketplace_item_category__read()
           ),
         initiator = Repo.preload(initiator, [:marketplace]) do
      all_item_categories(initiator.marketplace, opts)
    else
      _ -> {:error, "cannot get all item categories"}
    end
  end

  def all_item_categories(%Marketplace{} = marketplace, opts) do
    MarketplaceItemCategory
    |> where([category], category.marketplace_id == ^marketplace.id)
    |> then(fn query ->
      case Keyword.get(opts, :deleted_at) do
        true ->
          where(query, [category], not is_nil(category.deleted_at))

        false ->
          where(query, [category], is_nil(category.deleted_at))

        _ ->
          query
      end
    end)
    |> Repo.all()
  end

  def get_item_category(%MarketplaceAccount{} = initiator, id) when is_integer(id) do
    MarketplaceItemCategory
    |> where([category], category.id == ^id)
    |> where([category], category.marketplace_id == ^initiator.marketplace_id)
    |> Repo.one()
  end

  def create_item_category(%MarketplaceAccount{} = initiator, %{} = params) do
    with true <-
           Permissions.ok?(
             initiator,
             marketplaces__marketplace_item_category__create()
           ),
         initiator = Repo.preload(initiator, [:marketplace]) do
      create_item_category(initiator.marketplace, params)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot create item category"}
    end
  end

  def create_item_category(%Marketplace{} = marketplace, %{} = params) do
    with changeset = %Changeset{valid?: true} <- MarketplaceItemCategory.changeset(params) do
      changeset
      |> Changeset.put_assoc(:marketplace, marketplace)
      |> Repo.insert()
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot create item category"}
    end
  end

  def update_item_category(
        %MarketplaceAccount{} = initiator,
        %MarketplaceItemCategory{} = item_category,
        %{} = params
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             item_category,
             marketplaces__marketplace_item_category__update()
           ) do
      update_item_category(item_category, params)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot update item category"}
    end
  end

  def update_item_category(%MarketplaceItemCategory{} = item_category, %{} = params) do
    with changeset = %Changeset{valid?: true} <-
           MarketplaceItemCategory.changeset(item_category, params) do
      Repo.update(changeset)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot update item category"}
    end
  end

  def delete_item_category(
        %MarketplaceAccount{} = initiator,
        %MarketplaceItemCategory{} = item_category
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             item_category,
             marketplaces__marketplace_item_category__delete()
           ) do
      delete_item_category(item_category)
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot delete item category"}
    end
  end

  def delete_item_category(%MarketplaceItemCategory{} = item_category) do
    used? =
      MarketplaceItem
      |> where([item], item.category_id == ^item_category.id)
      |> where([item], is_nil(item.deleted_at))
      |> Repo.exists?()

    with false <- used? do
      item_category
      |> Changeset.change()
      |> Changeset.put_change(:deleted_at, Utils.naive_utc_now())
      |> Repo.update()
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot delete item category"}
    end
  end

  def all_items(a, b \\ [])

  def all_items(%MarketplaceItemCategory{} = item_category, opts) do
    MarketplaceItem
    |> where([item], item.category_id == ^item_category.id)
    |> then(fn query ->
      case Keyword.get(opts, :deleted_at) do
        true ->
          where(query, [item], not is_nil(item.deleted_at))

        false ->
          where(query, [item], is_nil(item.deleted_at))

        _ ->
          query
      end
    end)
    |> Repo.all()
  end

  def all_items(
        %MarketplaceAccount{} = initiator,
        %MarketplaceItemCategory{} = item_category,
        opts
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             item_category,
             marketplaces__marketplace_item_category__read()
           ),
         true <-
           Permissions.ok?(initiator, marketplaces__marketplace_item__read()) do
      all_items(item_category, opts)
    else
      _ -> {:error, "cannot get all items"}
    end
  end

  def get_item(
        %MarketplaceAccount{} = initiator,
        %MarketplaceItemCategory{} = item_category,
        item_id
      )
      when is_integer(item_id) do
    with true <-
           Permissions.ok?(
             initiator,
             item_category,
             marketplaces__marketplace_item_category__read()
           ),
         true <-
           Permissions.ok?(initiator, marketplaces__marketplace_item__read()) do
      get_item(item_category, item_id)
    else
      _ -> {:error, "cannot get an item"}
    end
  end

  def get_item(%MarketplaceItemCategory{} = item_category, item_id) when is_integer(item_id) do
    MarketplaceItem
    |> where([item], item.id == ^item_id)
    |> where([item], item.category_id == ^item_category.id)
    |> Repo.one()
  end

  def create_item(
        %MarketplaceAccount{} = initiator,
        %MarketplaceItemCategory{} = item_category,
        %{} = params
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             item_category,
             marketplaces__marketplace_item_category__read()
           ),
         true <-
           Permissions.ok?(
             initiator,
             marketplaces__marketplace_item__create()
           ) do
      create_item(item_category, params)
    else
      _ -> {:error, "cannot create an item"}
    end
  end

  def create_item(%MarketplaceItemCategory{} = item_category, %{} = params) do
    with changeset = %Changeset{valid?: true} <- MarketplaceItem.changeset(params),
         changeset = Changeset.put_assoc(changeset, :category, item_category) do
      Multi.new()
      |> Multi.insert(:item, changeset)
      |> Multi.run(:variant, fn repo, %{item: item} ->
        with {:variant_of, variant_of} when is_integer(variant_of) <-
               {:variant_of, Map.get(params, :variant_of)},
             original_item = %MarketplaceItem{} <- get_item(item_category, variant_of) do
          %MarketplaceItemVariant{}
          |> Changeset.change()
          |> Changeset.put_assoc(:item, original_item)
          |> Changeset.put_assoc(:variant, item)
          |> repo.insert()
        else
          {:variant_of, nil} -> {:ok, nil}
          _ -> {:error, "invalid variant"}
        end
      end)
      |> Repo.transaction()
      |> case do
        {:ok, _} = v -> v
        _ -> {:error, "cannot create an item"}
      end
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot create an item"}
    end
  end

  def update_item(%MarketplaceAccount{} = initiator, %MarketplaceItem{} = item, %{} = params) do
    with true <-
           Permissions.ok?(
             initiator,
             item,
             marketplaces__marketplace_item__update()
           ) do
      update_item(item, params)
    else
      _ -> {:error, "cannot update an item"}
    end
  end

  def update_item(%MarketplaceItem{} = item, %{} = params) do
    MarketplaceItem.changeset(item, params)
    |> Changeset.delete_change(:deleted_at)
    |> Repo.update()
  end

  def delete_item(%MarketplaceAccount{} = initiator, %MarketplaceItem{} = item) do
    with true <-
           Permissions.ok?(
             initiator,
             item,
             marketplaces__marketplace_item__delete()
           ) do
      delete_item(item)
    else
      _ -> {:error, "cannot delete an item"}
    end
  end

  def delete_item(%MarketplaceItem{} = item) do
    with false <- deleted_item?(item) do
      item
      |> Changeset.change()
      |> Changeset.put_change(:deleted_at, Utils.naive_utc_now())
      |> Repo.update()
    else
      {:error, _} = v -> v
      _ -> {:error, "cannot delete an item"}
    end
  end

  def deleted_item?(%MarketplaceItem{} = item) do
    not is_nil(item.deleted_at)
  end

  def create_item_asset(
        %MarketplaceAccount{} = initiator,
        %MarketplaceItem{} = item,
        %{} = params
      ) do
    with true <- Permissions.ok?(initiator, item, marketplaces__marketplace_item_asset__create()) do
      create_item_asset(item, params)
    else
      _ -> {:error, "cannot create an item asset"}
    end
  end

  def create_item_asset(%MarketplaceItem{} = item, %{} = params) do
    MarketplaceItemAsset.changeset(params)
    |> Changeset.put_assoc(:item, item)
    |> Repo.insert()
  end

  def all_item_assets(
        %MarketplaceAccount{} = initiator,
        %MarketplaceItem{} = item
      ) do
    with true <- Permissions.ok?(initiator, item, marketplaces__marketplace_item_asset__read()) do
      all_item_assets(item)
    else
      _ -> {:error, "cannot get all item assets"}
    end
  end

  def all_item_assets(%MarketplaceItem{} = item) do
    MarketplaceItemAsset
    |> where([asset], asset.item_id == ^item.id)
    |> Repo.all()
  end

  def get_item_asset(%MarketplaceAccount{} = initiator, %MarketplaceItem{} = item, id)
      when is_integer(id) do
    with true <- Permissions.ok?(initiator, item, marketplaces__marketplace_item_asset__read()) do
      get_item_asset(item, id)
    else
      _ -> {:error, "cannot get an item asset"}
    end
  end

  def get_item_asset(%MarketplaceItem{} = item, id) when is_integer(id) do
    MarketplaceItemAsset
    |> where([asset], asset.item_id == ^item.id)
    |> where([asset], asset.id == ^id)
    |> Repo.one()
  end

  def update_item_asset(
        %MarketplaceAccount{} = initiator,
        %MarketplaceItemAsset{} = asset,
        %{} = params
      ) do
    with true <- Permissions.ok?(initiator, asset, marketplaces__marketplace_item_asset__update()) do
      update_item_asset(asset, params)
    else
      _ -> {:error, "cannot update an item asset"}
    end
  end

  def update_item_asset(%MarketplaceItemAsset{} = asset, %{} = params) do
    MarketplaceItemAsset.changeset(asset, params)
    |> Repo.update()
  end

  def delete_item_asset(%MarketplaceAccount{} = initiator, %MarketplaceItemAsset{} = asset) do
    with true <- Permissions.ok?(initiator, asset, marketplaces__marketplace_item_asset__delete()) do
      delete_item_asset(asset)
    end
  end

  def delete_item_asset(%MarketplaceItemAsset{} = asset) do
    Repo.delete(asset)
  end

  def all_account_email_invitations(%MarketplaceAccount{} = initiator) do
    with true <-
           Permissions.ok?(initiator, marketplaces__marketplace_account_email_invitation__read()) do
      Repo.preload(initiator, [:marketplace])
      |> Map.get(:marketplace)
      |> all_account_email_invitations()
    else
      _ -> {:error, "cannot get an account email invitations"}
    end
  end

  def all_account_email_invitations(%Marketplace{} = marketplace) do
    MarketplaceAccountEmailInvitation
    |> join(:left, [invitation], role in assoc(invitation, :role))
    |> where([invitation, role], role.marketplace_id == ^marketplace.id)
    |> preload([_, role], role: role)
    |> Repo.all()
  end

  def create_account_email_invitation(
        %MarketplaceAccount{} = initiator,
        %MarketplaceAccountRole{} = role,
        %{} = params
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             role,
             marketplaces__marketplace_account_email_invitation__create()
           ) do
      create_account_email_invitation(role, params)
    else
      _ -> {:error, "cannot create an account email invitation"}
    end
  end

  def create_account_email_invitation(%MarketplaceAccountRole{} = role, %{} = params) do
    with changeset = %Changeset{valid?: true} <-
           MarketplaceAccountEmailInvitation.insert_changeset(params)
           |> Changeset.put_assoc(:role, role),
         email = Changeset.fetch_change!(changeset, :email) do
      if email_validation = get_account_email_invitation(:email, email) do
        {:ok, _} = delete_account_email_invitation(email_validation)
      end

      Repo.insert(changeset)
    end
  end

  def get_account_email_invitation(:email, email) when is_bitstring(email) do
    now = Utils.naive_utc_now()

    MarketplaceAccountEmailInvitation
    |> where([a], a.email == ^email and a.expired_at > ^now)
    |> order_by(desc: :id)
    |> Repo.one()
  end

  def get_account_email_invitation(:password, password) when is_bitstring(password) do
    now = Utils.naive_utc_now()

    MarketplaceAccountEmailInvitation
    |> where([a], a.password == ^password and a.expired_at > ^now)
    |> order_by(desc: :id)
    |> Repo.one()
  end

  def get_account_email_invitation(%MarketplaceAccount{} = initiator, id) when is_integer(id) do
    with true <-
           Permissions.ok?(initiator, marketplaces__marketplace_account_email_invitation__read()) do
      Repo.get(MarketplaceAccountEmailInvitation, id)
    end
  end

  def get_account_email_invitation(email, password)
      when is_bitstring(email) and is_bitstring(password) do
    now = Utils.naive_utc_now()

    MarketplaceAccountEmailInvitation
    |> where([a], a.email == ^email)
    |> where([a], a.password == ^password)
    |> where([a], a.expired_at > ^now)
    |> order_by(desc: :id)
    |> Repo.one()
  end

  def delete_account_email_invitation(
        %MarketplaceAccount{} = initiator,
        %MarketplaceAccountEmailInvitation{} = struct
      ) do
    with true <-
           Permissions.ok?(
             initiator,
             marketplaces__marketplace_account_email_invitation__delete()
           ) do
      delete_account_email_invitation(struct)
    else
      _ -> {:error, "cannot delete email invitation"}
    end
  end

  def delete_account_email_invitation(%MarketplaceAccountEmailInvitation{} = struct) do
    Repo.delete(struct)
  end

  def use_account_email_invitation(password) when is_bitstring(password) do
    with invitation = %MarketplaceAccountEmailInvitation{} <-
           get_account_email_invitation(:password, password),
         invitation = Repo.preload(invitation, role: [:marketplace]) do
      Multi.new()
      |> Multi.run(:account, fn repo, %{} ->
        Accounts.create_account(%{email: invitation.email}, repo: repo)
      end)
      |> Multi.run(:has_marketplace_account, fn repo, %{account: account} ->
        exists? =
          MarketplaceAccount
          |> where([marketplace_account], marketplace_account.account_id == ^account.id)
          |> where(
            [marketplace_account],
            marketplace_account.marketplace_id == ^invitation.role.marketplace_id
          )
          |> repo.exists?()

        (exists? && {:error, "marketplace account already exists"}) || {:ok, false}
      end)
      |> Multi.run(:marketplace_account, fn repo, %{account: account} ->
        add_account_to_marketplace(
          account,
          invitation.role.marketplace,
          invitation.role,
          repo: repo
        )
      end)
      |> Multi.delete(:delete_invitation, invitation)
      |> Repo.transaction()
      |> case do
        {:ok, _} = v -> v
        _ -> {:error, "cannot use an account email invitation"}
      end
    else
      _ -> {:error, "cannot use an account email invitation"}
    end
  end

  def all_warehouses(%MarketplaceAccount{} = initiator) do
    with true <- Permissions.ok?(initiator, marketplaces__warehouse__read()),
         initiator = Repo.preload(initiator, [:marketplace]) do
      all_warehouses(initiator.marketplace)
    else
      _ -> {:error, "cannot get all warehouses"}
    end
  end

  def all_warehouses(%Marketplace{} = marketplace) do
    MarketplaceWarehouse
    |> where([warehouse], warehouse.marketplace_id == ^marketplace.id)
    |> Repo.all()
  end

  def get_warehouse(%MarketplaceAccount{} = initiator, id) when is_integer(id) do
    with true <- Permissions.ok?(initiator, marketplaces__warehouse__read()),
         warehouse = %MarketplaceWarehouse{} <- get_warehouse(id),
         true <- Permissions.ok?(initiator, warehouse) do
      warehouse
    else
      _ -> {:error, "cannot get all warehouses"}
    end
  end

  def get_warehouse(id) when is_integer(id) do
    Repo.get(MarketplaceWarehouse, id)
  end

  def create_warehouse(%MarketplaceAccount{} = initiator, %{} = params) do
    with true <- Permissions.ok?(initiator, marketplaces__warehouse__create()),
         initiator = Repo.preload(initiator, [:marketplace]) do
      create_warehouse(initiator.marketplace, params)
    end
  end

  def create_warehouse(%Marketplace{} = marketplace, %{} = params) do
    MarketplaceWarehouse.changeset(params)
    |> Changeset.put_assoc(:marketplace, marketplace)
    |> Repo.insert()
  end

  def update_warehouse(
        %MarketplaceAccount{} = initiator,
        %MarketplaceWarehouse{} = warehouse,
        %{} = params
      ) do
    with true <- Permissions.ok?(initiator, warehouse, marketplaces__warehouse__update()) do
      update_warehouse(warehouse, params)
    end
  end

  def update_warehouse(%MarketplaceWarehouse{} = warehouse, %{} = params) do
    MarketplaceWarehouse.changeset(warehouse, params)
    |> Repo.update()
  end

  def all_warehouse_items(%MarketplaceAccount{} = initiator, %MarketplaceWarehouse{} = warehouse) do
    with true <- Permissions.ok?(initiator, warehouse, marketplaces__warehouse__read()) do
      all_warehouse_items(warehouse)
    end
  end

  def all_warehouse_items(%MarketplaceWarehouse{} = warehouse) do
    MarketplaceWarehouseItem
    |> where([item], item.warehouse_id == ^warehouse.id)
    |> preload([:marketplace_item])
    |> Repo.all()
  end

  def create_warehouse_item(
        %MarketplaceAccount{} = initiator,
        %MarketplaceWarehouse{} = warehouse,
        %MarketplaceItem{} = marketplace_item,
        %{} = params
      ) do
    with true <- Permissions.ok?(initiator, warehouse, marketplaces__warehouse_item__create()),
         true <- Permissions.ok?(initiator, marketplace_item) do
      create_warehouse_item(warehouse, marketplace_item, params)
    end
  end

  def create_warehouse_item(
        %MarketplaceWarehouse{} = warehouse,
        %MarketplaceItem{} = marketplace_item,
        %{} = params
      ) do
    with changeset = %Changeset{valid?: true} <- MarketplaceWarehouseItem.changeset(params),
         marketplace_item = Repo.preload(marketplace_item, [:category]),
         true <- warehouse.marketplace_id == marketplace_item.category.marketplace_id,
         false <-
           Repo.exists?(
             MarketplaceWarehouseItem
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
        %MarketplaceWarehouseItem{} = item,
        %{} = params
      ) do
    with true <- Permissions.ok?(initiator, item, marketplaces__warehouse_item__update()) do
      update_warehouse_item(item, params)
    end
  end

  def update_warehouse_item(%MarketplaceWarehouseItem{} = item, %{} = params) do
    MarketplaceWarehouseItem.changeset(item, params)
    |> Repo.update()
  end

  def create_subscription(
        %Marketplace{} = marketplace,
        %Subscription{} = subscription,
        %{} = params,
        opts \\ []
      ) do
    repo = Keyword.get(opts, :repo, Repo)

    MarketplaceSubscription.changeset(params)
    |> Changeset.put_assoc(:marketplace, marketplace)
    |> Changeset.put_assoc(:subscription, subscription)
    |> repo.insert()
  end
end
