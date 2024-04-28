defmodule Growio.Repo.Migrations.CreateTelegramBotCustomerMessages do
  use Ecto.Migration

  def change do
    create table(:marketplace_telegram_bot_customer_messages) do
      add(:text, :text, null: false)
      add(:marketplace_account_id, references(:marketplace_accounts))
      add(:customer_id, references(:marketplace_telegram_bot_customers), null: false)
    end

    alter table(:marketplace_telegram_bot_customers) do
      add(:conversation, :boolean)
    end
  end
end
