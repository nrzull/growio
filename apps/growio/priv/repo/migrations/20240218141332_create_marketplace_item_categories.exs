defmodule Growio.Repo.Migrations.CreateMarketplaceItemCategories do
  use Ecto.Migration

  def change do
    create table(:marketplace_item_categories) do
      add(:name, :string, null: false)
      add(:deleted_at, :naive_datetime)
      add(:marketplace_id, references(:marketplaces), null: false)
      timestamps()
    end
  end
end
