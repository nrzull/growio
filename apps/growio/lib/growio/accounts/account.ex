defmodule Growio.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccount
  alias Growio.Bots.TelegramBot

  @type t :: %__MODULE__{}
  @required ~w(email)a
  @optional ~w()a

  schema "accounts" do
    field(:email, :string)

    has_many(:telegram_bots, TelegramBot)
    many_to_many(:marketplaces, Marketplace, join_through: MarketplaceAccount)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_email()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(
      :email,
      ~r/^[a-z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-z0-9-]+(?:\.[a-z0-9-]+)*$/
    )
    |> unique_constraint(:email)
  end
end
