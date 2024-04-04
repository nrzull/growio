defmodule GrowioWeb.Views.MarketplaceAccountJSON do
  alias Growio.Marketplaces.MarketplaceAccount
  alias GrowioWeb.Views.AccountJSON
  alias GrowioWeb.Views.MarketplaceJSON
  alias GrowioWeb.Views.MarketplaceAccountRoleJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccount{} = account) do
    %{
      id: account.id,
      role: MarketplaceAccountRoleJSON.render(Map.get(account, :role)),
      marketplace: MarketplaceJSON.render(Map.get(account, :marketplace)),
      account: AccountJSON.render(Map.get(account, :account))
    }
  end

  def render(_value), do: nil
end
