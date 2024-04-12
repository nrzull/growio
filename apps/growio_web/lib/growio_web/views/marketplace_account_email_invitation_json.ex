defmodule GrowioWeb.Views.MarketplaceAccountEmailInvitationJSON do
  alias Growio.Marketplaces.MarketplaceAccountEmailInvitation
  alias GrowioWeb.Views.MarketplaceAccountRoleJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccountEmailInvitation{} = value) do
    %{
      id: value.id,
      email: value.email,
      role: MarketplaceAccountRoleJSON.render(Map.get(value, :role))
    }
  end

  def render(_value), do: nil
end
