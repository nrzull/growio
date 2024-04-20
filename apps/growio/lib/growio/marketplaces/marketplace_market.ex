defmodule Growio.Marketplaces.MarketplaceMarket do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceMarketItem

  @type t :: %__MODULE__{}
  @required ~w(address)a
  @optional ~w()a

  schema "marketplace_markets" do
    field(:address, :string)
    has_many(:items, MarketplaceMarketItem, foreign_key: :market_id)
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
