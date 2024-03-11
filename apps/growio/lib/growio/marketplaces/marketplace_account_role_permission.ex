defmodule Growio.Marketplaces.MarketplaceAccountRolePermission do
  use Ecto.Schema
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Permissions.Permission

  @type t :: %__MODULE__{}

  schema "marketplace_account_role_permissions" do
    belongs_to(:role, MarketplaceAccountRole)
    belongs_to(:permission, Permission)

    timestamps()
  end
end
