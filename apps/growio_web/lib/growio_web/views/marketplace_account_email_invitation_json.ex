defmodule GrowioWeb.Views.MarketplaceAccountEmailInvitationJson do
  alias Growio.Marketplaces.MarketplaceAccountEmailInvitation
  alias GrowioWeb.Views.MarketplaceAccountRoleJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccountEmailInvitation{} = invitation) do
    %{
      id: invitation.id,
      email: invitation.email,
      role: MarketplaceAccountRoleJSON.render(Map.get(invitation, :role))
    }
  end

  def render(_value), do: nil
end
