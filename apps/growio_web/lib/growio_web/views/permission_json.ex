defmodule GrowioWeb.Views.PermissionJSON do
  alias Growio.Permissions.Permission

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))
  def render(%Permission{} = permission), do: permission.name
  def render(value) when is_bitstring(value), do: value
  def render(_value), do: nil
end
