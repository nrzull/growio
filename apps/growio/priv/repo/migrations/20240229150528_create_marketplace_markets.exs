defmodule Growio.Repo.Migrations.CreateMarketplaceMarkets do
  use Ecto.Migration

  def change do
    create table(:marketplace_markets) do
      add(:name, :string, size: 64, null: false)
      add(:address, :string, size: 128)
      add(:marketplace_id, references(:marketplaces))
      timestamps()
    end
  end
end
