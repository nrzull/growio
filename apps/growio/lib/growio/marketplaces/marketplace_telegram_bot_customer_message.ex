defmodule Growio.Marketplaces.MarketplaceTelegramBotCustomerMessage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomer
  alias Growio.Marketplaces.MarketplaceAccount

  @required ~w(text)a
  @optional ~w(customer_id read)a

  schema "marketplace_telegram_bot_customer_messages" do
    field(:text, :string)
    field(:read, :boolean)
    belongs_to(:marketplace_account, MarketplaceAccount)
    belongs_to(:customer, MarketplaceTelegramBotCustomer)
    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
