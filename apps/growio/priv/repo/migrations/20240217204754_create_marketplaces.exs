defmodule Growio.Repo.Migrations.CreateMarketplaces do
  use Ecto.Migration

  def change do
    create table(:marketplaces) do
      add(:name, :string, size: 64, null: false)
      timestamps()
    end
  end
end
