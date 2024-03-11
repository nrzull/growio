defmodule Growio.Repo.Migrations.CreateMarketplaceAccountRoles do
  use Ecto.Migration

  def up do
    create table(:marketplace_account_roles) do
      add(:name, :string, size: 32, null: false)
      add(:description, :string)
      add(:priority, :integer, null: false)
      add(:marketplace_id, references(:marketplaces), null: false)
      timestamps()
    end

    alter table(:marketplace_accounts) do
      add(:role_id, references(:marketplace_account_roles))
    end
  end

  def down do
    alter table(:marketplace_accounts) do
      remove(:role_id, references(:marketplace_account_roles))
    end

    drop(table(:marketplace_account_roles))
  end
end
