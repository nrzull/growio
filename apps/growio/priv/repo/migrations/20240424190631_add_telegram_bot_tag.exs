defmodule Growio.Repo.Migrations.AddTelegramBotTag do
  use Ecto.Migration

  def change do
    alter table(:marketplace_telegram_bots) do
      add(:tag, :string)
    end

    create(unique_index(:marketplace_telegram_bots, [:tag]))
  end
end
