defmodule Growio.Repo.Migrations.CreateTelegramBots do
  use Ecto.Migration

  def change do
    create table(:marketplace_market_telegram_bots) do
      add(:name, :string)
      add(:description, :string)
      add(:token, :string, null: false)
      timestamps()
    end

    create(unique_index(:marketplace_market_telegram_bots, [:token]))
  end
end
