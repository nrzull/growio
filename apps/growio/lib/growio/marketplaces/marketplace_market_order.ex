defmodule Growio.Marketplaces.MarketplaceMarketOrder do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceMarket
  alias Growio.Marketplaces.MarketplaceMarketTelegramBotCustomer

  @type t :: %__MODULE__{}
  @required ~w(status payload)a
  @optional ~w()a

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "marketplace_market_orders" do
    field(:status, Ecto.Enum,
      values: [
        :init,
        :need_help,
        :need_price_approval,
        :need_payment,
        :done,
        :cancelled
      ]
    )

    field(:payload, :map)
    belongs_to(:market, MarketplaceMarket)
    belongs_to(:telegram_bot_customer, MarketplaceMarketTelegramBotCustomer)
    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
