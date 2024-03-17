defmodule GrowioWeb.Views.MarketplaceAccountRoleJSON do
  alias Growio.Marketplaces.MarketplaceAccountRole

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccountRole{} = role) do
    %{
      id: role.id,
      name: role.name,
      description: role.description,
      priority: role.priority
    }
  end
end
