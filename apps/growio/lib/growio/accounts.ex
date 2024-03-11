defmodule Growio.Accounts do
  import Ecto.Query
  alias Ecto.Changeset
  alias Growio.Utils
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

  def update_account_email_confirmation(%AccountEmailConfirmation{} = struct, %{} = params) do
    AccountEmailConfirmation.update_changeset(struct, params)
    |> Repo.update()
  end

  def get_active_account_email_confirmation(email) when is_bitstring(email) do
    now = Utils.naive_utc_now()

    AccountEmailConfirmation
    |> where([a], a.email == ^email and is_nil(a.used) and a.expired_at > ^now)
    |> order_by(desc: :id)
    |> Repo.one()
  end
end
