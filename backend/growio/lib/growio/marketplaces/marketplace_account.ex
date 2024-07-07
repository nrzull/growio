defmodule Growio.Marketplaces.MarketplaceAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Accounts.Account
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccountRole

  @type t :: %__MODULE__{}
  @required ~w(role_id)a

  schema "marketplace_accounts" do
    belongs_to(:account, Account)
    belongs_to(:marketplace, Marketplace)
    belongs_to(:role, MarketplaceAccountRole)

    field(:blocked_at, :naive_datetime)
    timestamps()
  end

  def update_changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
