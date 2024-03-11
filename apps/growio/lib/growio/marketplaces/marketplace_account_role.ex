defmodule Growio.Marketplaces.MarketplaceAccountRole do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces

  @type t :: %__MODULE__{}
  @required ~w(name priority)a
  @optional ~w(locked description)a

  schema "marketplace_account_roles" do
    field(:name, :string)
    field(:description, :string)
    field(:priority, :integer)
    field(:locked, :boolean)

    belongs_to(:marketplace, Marketplaces.Marketplace)
    has_many(:accounts, Marketplaces.MarketplaceAccount, foreign_key: :role_id)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
