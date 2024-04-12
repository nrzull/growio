defmodule GrowioWeb.Views.MarketplaceAccountJSON do
  alias Growio.Marketplaces.MarketplaceAccount
  alias GrowioWeb.Views.AccountJSON
  alias GrowioWeb.Views.MarketplaceJSON
  alias GrowioWeb.Views.MarketplaceAccountRoleJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccount{} = value) do
    %{
      id: value.id,
      role: MarketplaceAccountRoleJSON.render(Map.get(value, :role)),
      marketplace: MarketplaceJSON.render(Map.get(value, :marketplace)),
      account: AccountJSON.render(Map.get(value, :account))
    }
  end

  def render(_value), do: nil
end
