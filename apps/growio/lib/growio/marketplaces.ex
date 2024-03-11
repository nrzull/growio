defmodule Growio.Marketplaces do
  import Ecto.Query
  alias Ecto.Changeset
  alias Ecto.Multi
  alias Growio.Utils
  alias Growio.Repo
  alias Growio.Accounts.Account
  alias Growio.Permissions
  alias Growio.Permissions.PermissionDefs
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Marketplaces.MarketplaceAccountRolePermission

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
      |> Repo.transaction()
    end
  end

  def all_accounts(%Marketplace{} = marketplace, opts \\ []) do
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
           can_act?(
             initiator,
             PermissionDefs.marketplaces__marketplace_account__create()
           ),
         initiator = Repo.preload(initiator, [:role, :marketplace]),
         true <- initiator.role.priority < role.priority do
      add_account_to_marketplace(account, initiator.marketplace, role)
    else
      _ ->
        {:error, "cannot add an account to marketplace"}
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
           can_act?(
             initiator,
             account,
             PermissionDefs.marketplaces__marketplace_account__delete()
           ),
         false <- blocked_account?(account) do
      block_account(account)
    else
      _ ->
        {:error, "cannot block an account"}
    end
  end

  def block_account(%MarketplaceAccount{} = account) do
    account
    |> Changeset.change()
    |> Changeset.put_change(:blocked_at, Utils.naive_utc_now())
    |> Repo.update()
  end

  def undo_block_account(%MarketplaceAccount{} = initiator, %MarketplaceAccount{} = account) do
    with true <- initiator.marketplace_id == account.marketplace_id,
         true <-
           can_act?(
             initiator,
             account,
             PermissionDefs.marketplaces__marketplace_account__delete()
           ),
         true <- blocked_account?(account) do
      undo_block_account(account)
    else
      _ ->
        {:error, "cannot unblock an account"}
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

  def create_account_role(%MarketplaceAccount{} = initiator, %{} = params) do
    with true <-
           can_act?(initiator, PermissionDefs.marketplaces__marketplace_account_role__create()),
         initiator = Repo.preload(initiator, [:marketplace]) do
      create_account_role(initiator.marketplace, params)
    else
      _ ->
        {:error, "cannot create an account role"}
    end
  end

  def create_account_role(%Marketplace{} = marketplace, %{} = params) do
    with changeset = %Changeset{valid?: true} <- MarketplaceAccountRole.changeset(params) do
      changeset
      |> Changeset.put_assoc(:marketplace, marketplace)
      |> Changeset.put_change(:priority, length(all_account_roles(marketplace)) + 1)
      |> Repo.insert()
    end
  end

  def all_account_roles(%Marketplace{} = marketplace, opts \\ []) do
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
           can_act?(
             initiator,
             role,
             PermissionDefs.marketplaces__marketplace_account_role__create()
           ),
         true <-
           can_act?(
             initiator,
             account,
             PermissionDefs.marketplaces__marketplace_account_role__create()
           ) do
      assign_account_role(account, role)
    else
      _ ->
        {:error, "cannot assign an account role"}
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

  def update_account_role(%MarketplaceAccountRole{} = role, %{} = params) do
    if primary_account_role?(role) do
      {:error, "cannot update primary role"}
    else
      role
      |> MarketplaceAccountRole.changeset(params)
      |> Repo.update()
    end
  end

  def delete_account_role(%MarketplaceAccountRole{} = role) do
    cond do
      primary_account_role?(role) ->
        {:error, "cannot delete primary role"}

      Repo.exists?(where(MarketplaceAccount, [acc], acc.role_id == ^role.id)) ->
        {:error, "there are accounts that use current role"}

      not is_nil(role.deleted_at) ->
        {:error, "the role is already deleted"}

      true ->
        update_account_role(role, %{deleted_at: Utils.naive_utc_now()})
    end
  end

  def undo_delete_account_role(%MarketplaceAccountRole{} = role) do
    role
    |> Changeset.change()
    |> Changeset.force_change(:deleted_at, nil)
    |> Repo.update()
  end

  def get_account_role(%Marketplace{} = marketplace, name) do
    Repo.one(
      from(role in MarketplaceAccountRole,
        where: role.name == ^name and role.marketplace_id == ^marketplace.id
      )
    )
  end

  def set_account_role_permissions(
        %MarketplaceAccount{} = initiator,
        %MarketplaceAccountRole{} = role,
        [permission_name | _] = permission_names
      )
      when is_bitstring(permission_name) do
    with true <-
           can_act?(
             initiator,
             role,
             PermissionDefs.marketplaces__marketplace_account_role__update()
           ) do
      set_account_role_permissions(role, permission_names)
    else
      _ ->
        {:error, "cannot set account role permissions"}
    end
  end

  def set_account_role_permissions(
        %MarketplaceAccountRole{} = role,
        permission_names
      )
      when is_list(permission_names) do
    all_permissions = Permissions.all()

    is_valid_permissions =
      Enum.all?(permission_names, fn name ->
        Enum.any?(all_permissions, fn permission -> permission.name == name end)
      end)

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

      {:ok, nil}
    else
      _ ->
        {:error, "cannot set account role permissions"}
    end
  end

  def update_account_role_priorities(
        %MarketplaceAccount{} = initiator,
        [role_name | _] = role_names
      )
      when is_bitstring(role_name) do
    with true <-
           can_act?(
             initiator,
             PermissionDefs.marketplaces__marketplace_account_role__update()
           ),
         initiator = Repo.preload(initiator, [:marketplace]) do
      update_account_role_priorities(initiator.marketplace, role_names)
    else
      _ ->
        {:error, "cannot update account role priorities"}
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
      _ ->
        {:error, "cannot update account role priorities"}
    end
  end

  defp can_act?(
         %MarketplaceAccount{} = initiator,
         permission
       ) do
    with initiator = Repo.preload(initiator, role: [:permissions]),
         true <-
           Enum.any?(initiator.role.permissions, fn p ->
             p.name === permission
           end) do
      true
    else
      _ -> false
    end
  end

  defp can_act?(
         %MarketplaceAccount{} = initiator,
         %MarketplaceAccountRole{} = role,
         permission
       ) do
    with initiator = Repo.preload(initiator, role: [:permissions]),
         true <-
           Enum.any?(initiator.role.permissions, fn p ->
             p.name === permission
           end),
         true <- initiator.role.priority <= role.priority do
      true
    else
      _ -> false
    end
  end

  defp can_act?(
         %MarketplaceAccount{} = initiator,
         %MarketplaceAccount{} = account,
         permission
       ) do
    with initiator = Repo.preload(initiator, role: [:permissions]),
         account = Repo.preload(account, role: [:permissions]),
         true <-
           Enum.any?(initiator.role.permissions, fn p ->
             p.name === permission
           end),
         true <- initiator.role.priority < account.role.priority do
      true
    else
      _ -> false
    end
  end
end
