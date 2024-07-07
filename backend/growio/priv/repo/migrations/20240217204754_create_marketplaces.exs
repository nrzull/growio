defmodule Growio.Repo.Migrations.CreateMarketplaces do
  use Ecto.Migration

  def change do
    create table(:marketplaces) do
      add(:name, :string, size: 64, null: false)
      add(:currency, :string, size: 3)
      add(:address, :string, size: 128)
      timestamps()
    end
  end
end
