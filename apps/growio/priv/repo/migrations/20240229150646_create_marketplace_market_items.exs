defmodule Growio.Repo.Migrations.CreateMarketplaceMarketItems do
  use Ecto.Migration

  def change do
    create table(:marketplace_market_items) do
      add(:infinity, :boolean)
      add(:quantity, :integer)
      add(:marketplace_item_id, references(:marketplace_items))
      add(:market_id, references(:marketplace_markets))
      timestamps()
    end
  end
end
