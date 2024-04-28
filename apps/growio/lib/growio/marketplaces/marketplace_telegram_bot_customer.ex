defmodule Growio.Marketplaces.MarketplaceTelegramBotCustomer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceTelegramBot

  @type t :: %__MODULE__{}
  @required ~w(chat_id)a
  @optional ~w(conversation)a

  schema "marketplace_telegram_bot_customers" do
    field(:chat_id, :integer)
    field(:conversation, :boolean)
    belongs_to(:bot, MarketplaceTelegramBot)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:same_bot_and_chat,
      name: :marketplace_telegram_bot_customers_bot_chat_constraint
    )
  end
end
