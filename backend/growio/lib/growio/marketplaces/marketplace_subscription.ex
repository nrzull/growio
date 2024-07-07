defmodule Growio.Marketplaces.MarketplaceSubscription do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Subscriptions.Subscription

  @type t :: %__MODULE__{}
  @required ~w(expired_at)a
  @optional ~w()a

  schema "marketplace_subscriptions" do
    field(:expired_at, :naive_datetime)
    belongs_to(:marketplace, Marketplace)
    belongs_to(:subscription, Subscription)
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
