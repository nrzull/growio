defmodule Growio.AccountsFixture do
  alias Growio.Accounts
  alias Growio.Utils

  def account!(opts \\ []) do
    email = Keyword.get(opts, :email, gen_account_email())

    {:ok, account} =
      Accounts.create_account(%{
        email: Keyword.get(opts, :email, email)
      })

    account
  end

  def gen_account_email() do
    result = "#{Utils.gen_integer(1..6)}@example.com"

    if is_nil(Accounts.get_account_by(:email, result)) do
      result
    else
      gen_account_email()
    end
  end
end
