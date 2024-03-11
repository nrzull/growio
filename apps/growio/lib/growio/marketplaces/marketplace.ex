defmodule Growio.Marketplaces.Marketplace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Accounts.Account
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Bots.TelegramBot
  alias Growio.Marketplaces.MarketplaceItemCategory

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w()a

  schema "marketplaces" do
    field(:name, :string)

    has_many(:telegram_bots, TelegramBot)
    has_many(:account_roles, MarketplaceAccountRole)
    has_many(:item_categories, MarketplaceItemCategory)
    many_to_many(:accounts, Account, join_through: MarketplaceAccount)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_name()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_format(:name, ~r/^[a-zA-Zа-яА-ЯёЁ0-9\s]{1,64}$/)
    |> unique_constraint(:name)
  end
end
