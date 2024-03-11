defmodule Growio.Repo.Migrations.CreateMarketplaceAccounts do
  use Ecto.Migration

  def change do
    create table(:marketplace_accounts) do
      add(:account_id, references(:accounts))
      add(:marketplace_id, references(:marketplaces))
      timestamps()
    end
  end
end
