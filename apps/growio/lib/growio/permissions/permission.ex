defmodule Growio.Permissions.Permission do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Marketplaces.MarketplaceAccountRolePermission

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w()a

  schema "permissions" do
    field(:name, :string)

    many_to_many(:marketplace_account_roles, MarketplaceAccountRole,
      join_through: MarketplaceAccountRolePermission
    )

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:name)
  end
end
