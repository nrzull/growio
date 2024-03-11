defmodule GrowioWeb.Views.AccountJSON do
  alias Growio.Accounts.Account

  def render(%Account{} = account) do
    %{
      id: account.id,
      email: account.email
    }
  end
end
