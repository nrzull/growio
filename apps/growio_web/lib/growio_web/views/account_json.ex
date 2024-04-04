defmodule GrowioWeb.Views.AccountJSON do
  alias Growio.Accounts.Account

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%Account{} = account) do
    %{
      id: account.id,
      email: account.email
    }
  end

  def render(_value), do: nil
end
