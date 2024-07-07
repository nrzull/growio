defmodule Growio.Repo.Migrations.CreateMarketplaceAccountEmailInvitations do
  use Ecto.Migration

  def change do
    create table(:marketplace_account_email_invitations) do
      add(:email, :string, null: false)
      add(:password, :string, null: false)
      add(:expired_at, :naive_datetime, null: false)
      add(:role_id, references(:marketplace_account_roles), null: false)
      timestamps()
    end
  end
end
