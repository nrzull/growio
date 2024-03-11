defmodule Growio.Marketplaces do
  import Ecto.Query
  alias Ecto.Changeset
  alias Ecto.Multi
  alias Growio.Utils
  alias Growio.Repo
  alias Growio.Accounts.Account
  alias Growio.Permissions
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
      |> Multi.insert(:marketplace_account, fn %{marketplace: marketplace, role: role} ->
        %MarketplaceAccount{}
        |> Changeset.change()
        |> Changeset.put_assoc(:account, account)
        |> Changeset.put_assoc(:marketplace, marketplace)
        |> Changeset.put_assoc(:role, role)
      end)
      |> Repo.transaction()
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
    |> preload([:permissions])
    |> then(fn query ->
      if Keyword.get(opts, :deleted_at) do
        where(query, [role], not is_nil(role.deleted_at))
      else
        where(query, [role], is_nil(role.deleted_at))
      end
    end)
    |> Repo.all()
  end

  def primary_account_role?(%MarketplaceAccountRole{} = role) do
    role.priority === 0
  end

  def assign_account_role(
        %MarketplaceAccount{} = account,
        %MarketplaceAccountRole{} = role,
        opts \\ []
      ) do
    account = Repo.preload(account, [:role])
    force = Keyword.get(opts, :force, false)

    if primary_account_role?(account.role) and not force do
      {:error, "cannot change primary role"}
    else
      account
      |> Changeset.change()
      |> Changeset.put_change(:role_id, role.id)
      |> Repo.update()
    end
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

      Repo.exists?(from(acc in MarketplaceAccount, where: acc.role_id == ^role.id)) ->
        {:error, "there are accounts that use current rule"}

      true ->
        role
        |> Changeset.change()
        |> Changeset.put_change(:deleted_at, Utils.naive_utc_now())
        |> Repo.update()
    end
  end

  def get_account_role(%Marketplace{} = marketplace, name) do
    Repo.one(
      from(role in MarketplaceAccountRole,
        where: role.name == ^name and role.marketplace_id == ^marketplace.id
      )
    )
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
    end
  end

  def update_account_role_priorities(%Marketplace{} = marketplace, role_names)
      when is_list(role_names) do
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
    end
  end
end
