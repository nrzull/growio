defmodule Growio.Repo.Migrations.CreateMarketplaceAccountRolePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add(:name, :string, null: false)
      timestamps()
    end

    create(unique_index(:permissions, [:name]))

    create table(:marketplace_account_role_permissions) do
      add(:role_id, references(:marketplace_account_roles), null: false)
      add(:permission_id, references(:permissions), null: false)
      timestamps()
    end
  end
end
