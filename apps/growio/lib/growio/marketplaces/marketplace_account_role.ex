defmodule Growio.Marketplaces.MarketplaceAccountRole do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Marketplaces.MarketplaceAccountRolePermission
  alias Growio.Permissions.Permission

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w(description priority)a

  schema "marketplace_account_roles" do
    field(:name, :string)
    field(:description, :string)
    field(:priority, :integer)

    belongs_to(:marketplace, Marketplace)
    has_many(:accounts, MarketplaceAccount, foreign_key: :role_id)

    many_to_many(:permissions, Permission,
      join_through: MarketplaceAccountRolePermission,
      join_keys: [role_id: :id, permission_id: :id]
    )

    field(:deleted_at, :naive_datetime)
    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def owner_changeset(),
    do: changeset(%{name: "owner", priority: 0})
end
