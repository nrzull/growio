defmodule Growio.AccountsFixture do
  alias Growio.Accounts

  def account!(opts \\ []) do
    email = Keyword.get(opts, :email, gen_account_email())

    {:ok, account} =
      Accounts.create_account(%{
        email: Keyword.get(opts, :email, email)
      })

    account
  end

  def gen_account_email() do
    result = "#{gen_number(1..6)}@example.com"

    if is_nil(Accounts.get_account_by(:email, result)) do
      result
    else
      gen_account_email()
    end
  end

  defp gen_number(length_range) do
    length_range
    |> Enum.map(fn _ -> Enum.take_random(1..9, 1) |> List.first() |> Integer.to_string() end)
    |> Enum.join()
  end
end
