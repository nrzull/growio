defmodule Growio.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Bots.TelegramBot

  @type t :: %__MODULE__{}
  @required ~w(phone)a
  @optional ~w()a

  schema "accounts" do
    field(:phone, :string)

    has_many(:telegram_bots, TelegramBot)
    many_to_many(:marketplaces, Marketplace, join_through: MarketplaceAccount)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_phone()
  end

  defp validate_phone(changeset) do
    changeset
    |> validate_format(:phone, ~r/^\+\d{6,12}$/)
    |> unique_constraint(:phone)
  end
end
