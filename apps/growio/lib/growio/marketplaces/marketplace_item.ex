defmodule Growio.Marketplaces.MarketplaceItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias Growio.Marketplaces.MarketplaceItemVariant
  alias Growio.Marketplaces.MarketplaceItemAsset

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w(amount description deleted_at)a

  schema "marketplace_items" do
    field(:name, :string)
    field(:amount, :string)
    field(:description, :string)
    field(:deleted_at, :naive_datetime)
    belongs_to(:category, MarketplaceItemCategory)
    has_many(:assets, MarketplaceItemAsset, foreign_key: :item_id)
    many_to_many(:variants, __MODULE__, join_through: MarketplaceItemVariant)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
