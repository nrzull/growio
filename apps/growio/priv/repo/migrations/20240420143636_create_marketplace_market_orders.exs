defmodule Growio.Repo.Migrations.CreateMarketplaceMarketOrders do
  use Ecto.Migration

  def change do
    create table(:marketplace_market_orders, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:status, :string, null: false)
      add(:payload, :json, null: false)
      add(:market_id, references(:marketplace_markets), null: false)
      add(:telegram_bot_customer_id, references(:marketplace_market_telegram_bot_customers))
      timestamps()
    end
  end
end
