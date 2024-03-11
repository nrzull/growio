defmodule Growio.Repo.Migrations.CreateMarketplaceItemAssets do
  use Ecto.Migration

  def change do
    create table(:marketplace_item_assets) do
      add(:mimetype, :string, null: false)
      add(:src, :string)
      add(:item_id, references(:marketplace_items), null: false)
      timestamps()
    end
  end
end
