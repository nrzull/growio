defmodule Growio.Repo.Migrations.CreateMarketplaceItems do
  use Ecto.Migration

  def change do
    create table(:marketplace_items) do
      add(:name, :string, null: false)
      add(:price, :string, size: 32)
      add(:description, :text)
      add(:infinity, :boolean)
      add(:quantity, :integer)
      add(:deleted_at, :naive_datetime)
      add(:category_id, references(:marketplace_item_categories), null: false)
      timestamps()
    end

    alter table(:marketplace_items) do
      add(:origin_id, references(:marketplace_items))
    end
  end
end
