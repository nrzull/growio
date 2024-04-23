defmodule GrowioWeb.Views.MarketplaceTelegramBotJSON do
  alias Growio.Marketplaces.MarketplaceTelegramBot
  alias Growio.Marketplaces.MarketplaceTelegramBot

  def render(values) when is_list(values), do: Enum.map(values, &render(&1))

  def render(%MarketplaceTelegramBot{} = value) do
    %{
      id: value.id,
      token: value.token,
      name: value.name,
      description: value.description,
      short_description: value.short_description,
      welcome_message: value.welcome_message,
      marketplace_id: value.marketplace_id
    }
  end

  def render(_value), do: nil
end
