defmodule Growio.Repo.Migrations.CreateTelegramBots do
  use Ecto.Migration

  def change do
    create table(:telegram_bots) do
      add(:token, :string, null: false)
      add(:account_id, references(:accounts), null: false)
      add(:marketplace_id, references(:marketplaces))
      timestamps()
    end

    create(unique_index(:telegram_bots, [:token]))
  end
end
