defmodule Growio.Marketplaces do
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
      |> Multi.run(:permissions, fn _repo, %{} ->
        {:ok, Permissions.all()}
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
end
