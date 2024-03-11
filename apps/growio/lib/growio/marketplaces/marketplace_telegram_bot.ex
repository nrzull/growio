defmodule Growio.Marketplaces.MarketplaceTelegramBot do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace

  @type t :: %__MODULE__{}
  @required ~w(token)a
  @optional ~w()a

  schema "marketplace_telegram_bots" do
    field(:name, :string)
    field(:description, :string)
    field(:token, :string)
    belongs_to(:marketplace, Marketplace)

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
