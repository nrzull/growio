defmodule Growio.Repo.Migrations.CreateMarketplaceOrders do
  use Ecto.Migration

  def change do
    create table(:marketplace_orders, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:status, :string, null: false)
      add(:items, {:array, :map})
      add(:currency, :string)
      add(:payment_type, :string)
      add(:payment_provider, :string)
      add(:delivery_type, :string)
      add(:delivery_provider, :string)

      add(:marketplace_id, references(:marketplaces), null: false)
      add(:telegram_bot_customer_id, references(:marketplace_telegram_bot_customers))
      timestamps()
    end
  end
end
