defmodule Growio.Accounts do
  import Ecto.Query
  alias Growio.Accounts.Account
  alias Growio.Repo

  def get_account_by(:id, id) when is_integer(id) do
    Repo.get(Account, id)
  end

  def get_account_by(:email, email) when is_bitstring(email) do
    Repo.one(from(a in Account, where: a.email == ^email))
  end

  def create_account(%{} = params) do
    Repo.insert(Account.changeset(params))
  end
end
