defmodule GrowioWeb.Views.MarketplaceAccountRoleJSON do
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias GrowioWeb.Views.PermissionJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccountRole{} = role) do
    %{
      id: role.id,
      name: role.name,
      description: role.description,
      priority: role.priority,
      permissions: PermissionJSON.render(Map.get(role, :permissions))
    }
  end

  def render(_value), do: nil
end
