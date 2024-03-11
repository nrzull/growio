defmodule Growio.Repo.Migrations.CreateMarketplaceItemsAndVariants do
  use Ecto.Migration

  def change do
    create table(:marketplace_items) do
      add(:name, :string, null: false)
      add(:description, :text)
      add(:quantity, :integer)
      add(:category_id, references(:marketplace_item_categories), null: false)
      timestamps()
    end

    create table(:marketplace_item_variants) do
      add(:item_id, references(:marketplace_items), null: false)
      add(:variant_id, references(:marketplace_items), null: false)
      timestamps()
    end
  end
end
