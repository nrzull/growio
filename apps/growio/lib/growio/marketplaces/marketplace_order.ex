defmodule Growio.Marketplaces.MarketplaceOrder do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomer

  @type t :: %__MODULE__{}
  @required ~w(status)a
  @optional ~w(items currency payment_type payment_provider delivery_type delivery_provider)a

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "marketplace_orders" do
    field(:status, Ecto.Enum,
      values: [
        :init,
        :need_payment,
        :preparing,
        :can_be_taken,
        :can_be_delivered,
        :delivering,
        :done,
        :cancelled
      ]
    )

    field(:items, {:array, :map})
    field(:currency, Ecto.Enum, values: [:USD, :RUB, :KGS])
    field(:payment_type, Ecto.Enum, values: [:online, :in_place])
    field(:payment_provider, Ecto.Enum, values: [:system])
    field(:delivery_type, Ecto.Enum, values: [:export, :self_export])
    field(:delivery_provider, Ecto.Enum, values: [:merchant])

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

  def status_changes do
    %{
      init: [:need_payment, :preparing],
      need_payment: [:preparing, :cancelled],
      preparing: [:can_be_taken, :can_be_delivered, :cancelled],
      can_be_taken: [:done, :cancelled],
      can_be_delivered: [:delivering, :cancelled],
      delivering: [:done, :cancelled],
      done: [],
      cancelled: []
    }
  end

  def valid_status_change?(from, to) do
    values = Map.get(status_changes(), from, [])
    String.to_existing_atom(to) in values
  end
end
