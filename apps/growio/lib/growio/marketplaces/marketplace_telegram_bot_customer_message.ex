defmodule Growio.Marketplaces.MarketplaceTelegramBotCustomerMessage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomer
  alias Growio.Marketplaces.MarketplaceAccount

  schema "marketplace_telegram_bot_customer_messages" do
    field(:text, :string)
    belongs_to(:marketplace_account, MarketplaceAccount)
    belongs_to(:customer, MarketplaceTelegramBotCustomer)
    timestamps()
  end
end
