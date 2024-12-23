defmodule Growio.Marketplaces.MarketplaceItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias Growio.Marketplaces.MarketplaceItemAsset

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w(price description deleted_at infinity quantity category_id origin_id)a

  schema "marketplace_items" do
    field(:name, :string)
    field(:price, :string)
    field(:description, :string)
    field(:infinity, :boolean)
    field(:quantity, :integer)
    field(:deleted_at, :naive_datetime)
    belongs_to(:origin, __MODULE__)
    belongs_to(:category, MarketplaceItemCategory)
    has_many(:assets, MarketplaceItemAsset, foreign_key: :item_id)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
