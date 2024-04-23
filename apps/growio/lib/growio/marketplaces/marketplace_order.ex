defmodule Growio.Marketplaces.MarketplaceOrder do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomer

  @type t :: %__MODULE__{}
  @required ~w(status payload)a
  @optional ~w()a

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "marketplace_orders" do
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
    belongs_to(:marketplace, Marketplace)
    belongs_to(:telegram_bot_customer, MarketplaceTelegramBotCustomer)
    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
