defmodule GrowioWeb.Views.MarketplaceAccountRoleJSON do
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias GrowioWeb.Views.PermissionJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccountRole{} = value) do
    %{
      id: value.id,
      name: value.name,
      description: value.description,
      priority: value.priority,
      permissions: PermissionJSON.render(Map.get(value, :permissions))
    }
  end

  def render(_value), do: nil
end
