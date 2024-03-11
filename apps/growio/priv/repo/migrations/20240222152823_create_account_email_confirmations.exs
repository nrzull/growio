defmodule Growio.Repo.Migrations.CreateAccountEmailConfirmations do
  use Ecto.Migration

  def change do
    create table(:account_email_confirmations) do
      add(:email, :string, null: false)
      add(:code, :string, null: false)
      add(:used, :boolean)
      add(:expired_at, :naive_datetime, null: false)
      timestamps()
    end
  end
end
