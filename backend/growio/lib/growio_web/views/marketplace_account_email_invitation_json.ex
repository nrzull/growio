defmodule GrowioWeb.Views.MarketplaceAccountEmailInvitationJSON do
  alias Growio.Marketplaces.MarketplaceAccountEmailInvitation
  alias GrowioWeb.Views.MarketplaceAccountRoleJSON
  alias GrowioWeb.Views.MarketplaceJSON

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceAccountEmailInvitation{} = value) do
    %{
      id: value.id,
      email: value.email,
      role: MarketplaceAccountRoleJSON.render(Map.get(value, :role)),
      marketplace:
        if marketplace = get_in(value, [Access.key(:role), Access.key(:marketplace)]) do
          MarketplaceJSON.render(marketplace)
        else
          nil
        end
    }
  end

  def render(_value), do: nil
end
