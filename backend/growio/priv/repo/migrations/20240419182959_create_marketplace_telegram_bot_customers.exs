defmodule Growio.Repo.Migrations.CreateMarketplaceTelegramBotCustomers do
  use Ecto.Migration

  def change do
    create table(:marketplace_telegram_bot_customers) do
      add(:chat_id, :bigint)
      add(:bot_id, references(:marketplace_telegram_bots))
      timestamps()
    end

    create(
      unique_index(:marketplace_telegram_bot_customers, [:chat_id, :bot_id],
        name: :marketplace_telegram_bot_customers_bot_chat_constraint
      )
    )
  end
end
