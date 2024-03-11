defmodule Growio.Marketplaces do
  import Ecto.Query
  alias Ecto.Changeset
  alias Ecto.Multi
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
              inserted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
              updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
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

  def all_account_roles(%Marketplace{} = marketplace) do
    Repo.all(
      from(
        role in MarketplaceAccountRole,
        where: role.marketplace_id == ^marketplace.id,
        order_by: [asc: :priority],
        preload: [:permissions]
      )
    )
  end

  def get_account_role(%Marketplace{} = marketplace, name) do
    Repo.one(
      from(role in MarketplaceAccountRole,
        where: role.name == ^name and role.marketplace_id == ^marketplace.id
      )
    )
  end

  def update_priorities(%Marketplace{} = marketplace, [_ | _] = role_names) do
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

      {:ok, %{update_all: keywords}} =
        Multi.new()
        |> Multi.run(:update_all, fn repo, %{} ->
          {:ok, Enum.map(changesets, fn changeset -> repo.update(changeset) end)}
        end)
        |> Repo.transaction()

      {:ok,
       keywords
       |> Enum.filter(fn {status, _} -> status === :ok end)
       |> Enum.map(fn {_, value} -> value end)}
    end
  end
end
