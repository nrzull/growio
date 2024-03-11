defmodule Growio.Marketplaces.MarketplaceAccount do
  use Ecto.Schema
  alias Growio.Accounts.Account
  alias Growio.Marketplaces.Marketplace
  alias Growio.Marketplaces.MarketplaceAccountRole

  @type t :: %__MODULE__{}

  schema "marketplace_accounts" do
    belongs_to(:account, Account)
    belongs_to(:marketplace, Marketplace)
    belongs_to(:role, MarketplaceAccountRole)

    field(:blocked_at, :naive_datetime)
    timestamps()
  end
end
