defmodule Growio.Marketplaces.Marketplace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Accounts
  alias Growio.Marketplaces

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w()a

  schema "marketplaces" do
    field(:name, :string)

    has_many(:account_roles, Marketplaces.MarketplaceAccountRole)

    many_to_many(:accounts, Accounts.Account, join_through: Marketplaces.MarketplaceAccount)

    timestamps()
  end

  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_name()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_format(:name, ~r/^[a-zA-Zа-яА-ЯёЁ0-9\s]{1,64}$/)
    |> unique_constraint(:name)
  end
end
