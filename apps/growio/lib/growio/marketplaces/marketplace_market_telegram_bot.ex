defmodule Growio.Marketplaces.MarketplaceMarketTelegramBot do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceMarket
  alias Growio.Marketplaces.MarketplaceMarketTelegramBotCustomer

  @type t :: %__MODULE__{}
  @required ~w(token marketplace_market_id)a
  @optional ~w()a

  schema "marketplace_market_telegram_bots" do
    field(:token, :string)
    belongs_to(:marketplace_market, MarketplaceMarket)
    has_many(:customers, MarketplaceMarketTelegramBotCustomer, foreign_key: :bot_id)
    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:token)
  end
end
