defmodule Growio.Accounts do
  import Ecto.Query
  alias Ecto.Changeset
  alias Growio.Repo
  alias Growio.Accounts.Account
  alias Growio.Accounts.AccountEmailConfirmation

  def get_account_by(:id, id) when is_integer(id) do
    Repo.get(Account, id)
  end

  def get_account_by(:email, email) when is_bitstring(email) do
    Repo.get_by(Account, email: email)
  end

  def create_account(%{} = params) do
    with changeset = %Changeset{valid?: true} <- Account.insert_changeset(params) do
      {:ok,
       get_account_by(:email, Changeset.fetch_field!(changeset, :email)) ||
         Repo.insert!(changeset)}
    end
  end

  def create_account_email_confirmation(%{} = params) do
    with changeset = %Changeset{valid?: true} <-
           AccountEmailConfirmation.insert_changeset(params) do
      {:ok,
       get_active_account_email_confirmation(Ecto.Changeset.fetch_field!(changeset, :email)) ||
         Repo.insert!(changeset)}
    end
  end

  def get_active_account_email_confirmation(email) when is_bitstring(email) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Repo.one(
      from(a in AccountEmailConfirmation,
        where:
          a.email == ^email and
            is_nil(a.used) and
            a.expired_at > ^now,
        order_by: [desc: :id]
      )
    )
  end
end
