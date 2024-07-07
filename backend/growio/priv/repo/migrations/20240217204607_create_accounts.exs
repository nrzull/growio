defmodule Growio.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:email, :string, size: 128, null: false)
      timestamps()
    end

    create(unique_index(:accounts, [:email]))
  end
end
