defmodule GrowioWeb.Views.MarketplaceTelegramBotJSON do
  alias Growio.Marketplaces.MarketplaceTelegramBot
  alias Growio.Marketplaces.MarketplaceTelegramBot

  def render(values, opts \\ [])

  def render(values, opts) when is_list(values), do: Enum.map(values, &render(&1, opts))

  def render(%MarketplaceTelegramBot{} = value, opts) do
    payload = %{
      id: value.id,
      token: value.token,
      name: value.name,
      tag: value.tag,
      description: value.description,
      short_description: value.short_description,
      welcome_message: value.welcome_message,
      marketplace_id: value.marketplace_id
    }

    payload =
      if Keyword.get(opts, :drop) do
        Map.drop(payload, Keyword.get(opts, :drop))
      else
        payload
      end

    payload =
      if Keyword.get(opts, :take) do
        Map.take(payload, Keyword.get(opts, :take))
      else
        payload
      end

    Map.put(payload, :is_telegram, true)
  end

  def render(_value, _), do: nil
end
