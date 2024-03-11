defmodule Growio.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:phone, :string, size: 16, null: false)
      timestamps()
    end

    create(unique_index(:accounts, [:phone]))
  end
end
