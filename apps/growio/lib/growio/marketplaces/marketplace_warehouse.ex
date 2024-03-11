defmodule Growio.Marketplaces.MarketplaceWarehouse do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceWarehouseItem

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w(address)a

  schema "marketplace_warehouses" do
    field(:name, :string)
    field(:address, :string)
    has_many(:items, MarketplaceWarehouseItem, foreign_key: :warehouse_id)
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
