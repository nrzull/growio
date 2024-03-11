defmodule Growio.Warehouses.WarehouseItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Warehouses.Warehouse

  @type t :: %__MODULE__{}
  @required ~w()a
  @optional ~w(infinity quantity)a

  schema "warehouse_items" do
    field(:infinity, :boolean)
    field(:quantity, :integer)
    belongs_to(:marketplace_item, MarketplaceItem)
    belongs_to(:warehouse, Warehouse)
    timestamps()
  end

  def changeset(%{} = params),
    do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
