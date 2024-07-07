defmodule Growio.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccount

  @type t :: %__MODULE__{}
  @required ~w(email)a
  @optional ~w()a

  schema "accounts" do
    field(:email, :string)
    many_to_many(:marketplaces, Marketplace, join_through: MarketplaceAccount)

    timestamps()
  end

  def insert_changeset(%{} = params),
    do: insert_changeset(%__MODULE__{}, params)

  def insert_changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_email()
  end

  def validate_email(changeset) do
    changeset
    |> validate_format(
      :email,
      ~r/^[a-z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-z0-9-]+(?:\.[a-z0-9-]+)*$/
    )
    |> unique_constraint(:email)
  end
end
