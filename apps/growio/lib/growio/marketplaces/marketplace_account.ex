defmodule Growio.Marketplaces.MarketplaceAccount do
  use Ecto.Schema
  alias Growio.Accounts
  alias Growio.Marketplaces

  @type t :: %__MODULE__{}

  schema "marketplace_accounts" do
    belongs_to(:account, Accounts.Account)
    belongs_to(:marketplace, Marketplaces.Marketplace)
    belongs_to(:role, Marketplaces.MarketplaceAccountRole, on_replace: :nilify)

    timestamps()
  end
end
