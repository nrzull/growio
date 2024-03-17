defmodule GrowioWeb.Views.MarketplaceAccountJSON do
  alias Growio.Marketplaces.MarketplaceAccount
  alias GrowioWeb.Views.MarketplaceJSON
  alias GrowioWeb.Views.MarketplaceAccountRoleJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccount{} = account) do
    %{
      id: account.id,
      role: MarketplaceAccountRoleJSON.render(account.role),
      marketplace: MarketplaceJSON.render(account.marketplace)
    }
  end
end
