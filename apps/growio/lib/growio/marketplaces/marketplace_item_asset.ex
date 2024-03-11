defmodule Growio.Marketplaces.MarketplaceItemAsset do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceItem

  @type t :: %__MODULE__{}
  @required ~w(mimetype src)a
  @optional ~w()a

  schema "marketplace_item_assets" do
    field(:mimetype, :string)
    field(:src, :string)

    belongs_to(:item, MarketplaceItem)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
