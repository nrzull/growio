defmodule Growio.Repo.Migrations.CreateMarketplaceSubscriptions do
  use Ecto.Migration

  def change do
    create table(:marketplace_subscriptions) do
      add(:marketplace_id, references(:marketplaces))
      add(:subscription_id, references(:subscriptions))
      add(:expired_at, :naive_datetime)
      timestamps()
    end
  end
end
