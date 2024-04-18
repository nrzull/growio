defmodule GrowioWeb.Views.MarketplaceMarketTelegramBotJSON do
  alias Growio.Marketplaces.MarketplaceMarketTelegramBot

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceMarketTelegramBot{} = value) do
    %{
      id: value.id,
      name: value.name,
      description: value.description,
      token: value.token,
      marketplace_market_id: value.marketplace_market_id
    }
  end

  def render(_value), do: nil
end
