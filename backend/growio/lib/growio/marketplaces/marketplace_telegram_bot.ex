defmodule Growio.Marketplaces.MarketplaceTelegramBot do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomer

  @type t :: %__MODULE__{}
  @required ~w(token)a
  @optional ~w(name description tag short_description welcome_message)a

  schema "marketplace_telegram_bots" do
    field(:token, :string)
    field(:name, :string)
    field(:tag, :string)
    field(:description, :string)
    field(:short_description, :string)
    field(:welcome_message, :string)
    belongs_to(:marketplace, Marketplace)
    has_many(:customers, MarketplaceTelegramBotCustomer, foreign_key: :bot_id)
    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:token)
    |> unique_constraint(:tag)
  end
end
