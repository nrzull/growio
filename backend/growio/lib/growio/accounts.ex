defmodule Growio.Accounts do
  import Ecto.Query
  alias Ecto.Changeset
  alias Growio.Utils
  alias Growio.Repo
  alias Growio.Accounts.Account
  alias Growio.Accounts.AccountEmailOTP

  def get_account_by(:id, id) when is_integer(id) do
    Repo.get(Account, id)
  end

  def get_account_by(:email, email) when is_bitstring(email) do
    Repo.get_by(Account, email: email)
  end

  def create_account(%{} = params, opts \\ []) do
    repo = Keyword.get(opts, :repo, Repo)

    with changeset = %Changeset{valid?: true} <- Account.insert_changeset(params) do
      {:ok,
       get_account_by(:email, Changeset.fetch_field!(changeset, :email)) ||
         repo.insert!(changeset)}
    end
  end

  def create_account_email_otp(%{} = params) do
    with changeset = %Changeset{valid?: true} <-
           AccountEmailOTP.insert_changeset(params) do
      email = Ecto.Changeset.fetch_change!(changeset, :email)

      if active_otp = get_active_account_email_otp(email) do
        {:ok, _} = delete_account_email_otp(active_otp)
      end

      Repo.insert(changeset)
    end
  end

  def delete_account_email_otp(%AccountEmailOTP{} = struct) do
    Repo.delete(struct)
  end

  def get_active_account_email_otp(email) when is_bitstring(email) do
    now = Utils.naive_utc_now()

    AccountEmailOTP
    |> where([a], a.email == ^email and a.expired_at > ^now)
    |> order_by(desc: :id)
    |> Repo.one()
  end
end
