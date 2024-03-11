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
    with marketplace_changeset = %Changeset{valid?: true} <- Marketplace.changeset(params),
         role_changeset = %Changeset{valid?: true} <-
           MarketplaceAccountRole.changeset(%{
             name: "owner",
             locked: true,
             priority: 1
           }) do
      result =
        Multi.new()
        |> Multi.insert(:marketplace, marketplace_changeset)
        |> Multi.insert(:role, fn %{marketplace: marketplace} ->
          Changeset.put_assoc(role_changeset, :marketplace, marketplace)
        end)
        |> Multi.insert(:marketplace_account, fn %{marketplace: marketplace, role: role} ->
          %MarketplaceAccount{}
          |> Changeset.change()
          |> Changeset.put_assoc(:account, account)
          |> Changeset.put_assoc(:marketplace, marketplace)
          |> Changeset.put_assoc(:role, role)
        end)
        |> Repo.transaction()

      case result do
        {:ok, %{role: role}} = v ->
          tasks =
            Enum.map(Permissions.all(), fn permission ->
              c =
                Changeset.change(%MarketplaceAccountRolePermission{})
                |> Changeset.put_assoc(:role, role)
                |> Changeset.put_assoc(:permission, permission)

              Task.async(fn -> Repo.insert!(c) end)
            end)

          Task.await_many(tasks)
          v

        v ->
          v
      end
    end
  end
end
