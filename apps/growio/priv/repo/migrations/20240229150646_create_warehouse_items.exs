defmodule Growio.Repo.Migrations.CreateWarehouseItems do
  use Ecto.Migration

  def change do
    create table(:warehouse_items) do
      add(:infinity, :boolean)
      add(:quantity, :integer)
      add(:marketplace_item_id, references(:marketplace_items))
      add(:warehouse_id, references(:warehouses))
      timestamps()
    end
  end
end
