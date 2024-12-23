defmodule Growio.Marketplaces.Marketplace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Accounts.Account
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Marketplaces.MarketplaceItemCategory
  alias Growio.Marketplaces.MarketplaceOrder

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w(currency address)a

  schema "marketplaces" do
    field(:name, :string)
    field(:currency, :string)
    field(:address, :string)

    has_many(:account_roles, MarketplaceAccountRole)
    has_many(:item_categories, MarketplaceItemCategory)
    has_many(:orders, MarketplaceOrder)
    many_to_many(:accounts, Account, join_through: MarketplaceAccount)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
