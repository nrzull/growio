defmodule Growio.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:subscriptions, [:name]))
  end
end
