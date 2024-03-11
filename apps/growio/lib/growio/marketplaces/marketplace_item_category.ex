defmodule Growio.Marketplaces.MarketplaceItemCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceItem
  alias Growio.Marketplaces.Marketplace

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w(deleted_at)a

  schema "marketplace_item_categories" do
    field(:name, :string)
    field(:deleted_at, :naive_datetime)

    belongs_to(:marketplace, Marketplace)
    has_many(:items, MarketplaceItem, foreign_key: :category_id)

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
