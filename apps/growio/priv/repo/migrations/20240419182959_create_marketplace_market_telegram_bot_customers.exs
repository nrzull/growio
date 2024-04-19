defmodule Growio.Repo.Migrations.CreateMarketplaceMarketTelegramBotCustomers do
  use Ecto.Migration

  def change do
    create table(:marketplace_market_telegram_bot_customers) do
      add(:chat_id, :bigint)
      add(:bot_id, references(:marketplace_market_telegram_bots))
      timestamps()
    end

    create(
      unique_index(:marketplace_market_telegram_bot_customers, [:chat_id, :bot_id],
        name: :marketplace_market_telegram_bot_customers_bot_chat_constraint
      )
    )
  end
end
