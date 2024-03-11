defmodule Growio.Repo.Migrations.CreateMarketplaceWarehouseItems do
  use Ecto.Migration

  def change do
    create table(:marketplace_warehouse_items) do
      add(:infinity, :boolean)
      add(:quantity, :integer)
      add(:marketplace_item_id, references(:marketplace_items))
      add(:warehouse_id, references(:marketplace_warehouses))
      timestamps()
    end
  end
end
