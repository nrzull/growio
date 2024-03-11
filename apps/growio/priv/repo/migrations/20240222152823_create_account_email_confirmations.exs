defmodule Growio.Repo.Migrations.CreateAccountEmailOTP do
  use Ecto.Migration

  def change do
    create table(:account_email_otp) do
      add(:email, :string, null: false)
      add(:password, :string, null: false)
      add(:expired_at, :naive_datetime, null: false)
      timestamps()
    end
  end
end
