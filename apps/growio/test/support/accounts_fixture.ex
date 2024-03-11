defmodule Growio.AccountsFixture do
  alias Growio.Accounts

  def account!(opts \\ []) do
    {:ok, account} =
      Accounts.create_account(%{
        phone: Keyword.get(opts, :phone, gen_account_phone())
      })

    account
  end

  def gen_account_phone() do
    result = "+#{do_gen_account_phone(1..6)}"

    if is_nil(Accounts.get_account_by(:phone, result)) do
      result
    else
      gen_account_phone()
    end
  end

  defp do_gen_account_phone(range) do
    range
    |> Enum.map(fn _ -> Enum.take_random(1..9, 1) |> List.first() |> Integer.to_string() end)
    |> Enum.join()
  end
end
