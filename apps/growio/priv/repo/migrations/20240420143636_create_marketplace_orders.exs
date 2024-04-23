defmodule Growio.Repo.Migrations.CreateMarketplaceOrders do
  use Ecto.Migration

  def change do
    create table(:marketplace_orders, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:status, :string, null: false)
      add(:payload, :json, null: false)
      add(:marketplace_id, references(:marketplaces), null: false)
      add(:telegram_bot_customer_id, references(:marketplace_telegram_bot_customers))
      timestamps()
    end
  end
end
