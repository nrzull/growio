defmodule Growio.Warehouses.Warehouse do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Warehouses.WarehouseItem

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w(address)a

  schema "warehouses" do
    field(:name, :string)
    field(:address, :string)
    has_many(:items, WarehouseItem)
    belongs_to(:marketplace, Marketplace)
    timestamps()
  end

  def changeset(%{} = params),
    do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
