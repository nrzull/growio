defmodule Growio.Repo.Migrations.CreateTelegramBots do
  use Ecto.Migration

  def change do
    create table(:marketplace_market_telegram_bots) do
      add(:token, :string, null: false)
      add(:name, :string)
      add(:description, :text)
      add(:short_description, :text)
      add(:welcome_message, :text)
      timestamps()
    end

    create(unique_index(:marketplace_market_telegram_bots, [:token]))
  end
end
