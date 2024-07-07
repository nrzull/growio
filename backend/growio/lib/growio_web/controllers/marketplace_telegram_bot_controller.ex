defmodule GrowioWeb.Controllers.MarketplaceTelegramBotController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceTelegramBot
  alias Growio.Marketplaces.MarketplaceTelegramBotCustomer
  alias GrowioWeb.Views.MarketplaceTelegramBotJSON
  alias GrowioWeb.Views.MarketplaceTelegramBotCustomerJSON
  alias GrowioWeb.Views.MarketplaceTelegramBotCustomerMessageJSON
  alias GrowioWeb.Channels.CustomerChannel
  alias GrowioTelegram.MarketBot

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_telegram_bots"])

  operation(:index_self,
    summary: "get self marketplace telegram bot",
    responses: [ok: {"", "application/json", Schemas.MarketplaceTelegramBot}]
  )

  def index_self(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    with bot = %MarketplaceTelegramBot{} <-
           Marketplaces.get_telegram_bot(marketplace_account) do
      Conn.ok(conn, MarketplaceTelegramBotJSON.render(bot))
    end
  end

  operation(:update_self,
    summary: "update self marketplace telegram bot",
    request_body: {"", "application/json", Schemas.MarketplaceTelegramBot, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceTelegramBot}]
  )

  def update_self(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        params
      ) do
    with bot = %MarketplaceTelegramBot{} <-
           Marketplaces.get_telegram_bot(marketplace_account),
         {:ok, updated_bot} <-
           Marketplaces.update_telegram_bot(marketplace_account, bot, params) do
      if bot.token === updated_bot.token do
        MarketBot.update_bot(updated_bot)
      else
        MarketBot.restart_bot(bot.token, updated_bot.token)
        MarketBot.update_bot(updated_bot)
      end

      Conn.ok(conn, MarketplaceTelegramBotJSON.render(updated_bot))
    end
  end

  operation(:create,
    summary: "create marketplace telegram bot",
    request_body: {"", "application/json", Schemas.MarketplaceTelegramBot, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceTelegramBot}]
  )

  def create(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        params
      ) do
    with {:ok, %MarketplaceTelegramBot{} = bot} <-
           Marketplaces.create_telegram_bot(marketplace_account, params) do
      MarketBot.start_bot(bot.token)
      Conn.ok(conn, MarketplaceTelegramBotJSON.render(bot))
    end
  end

  operation(:delete,
    summary: "delete marketplace telegram bot",
    parameters: [
      id: [in: :path, description: "telegram bot id", type: :integer]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceTelegramBot}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id}
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         {:ok, deleted_telegram_bot} <-
           Marketplaces.delete_telegram_bot(marketplace_account, id) do
      Conn.ok(conn, MarketplaceTelegramBotJSON.render(deleted_telegram_bot))
    end
  end

  operation(:index_self_customers,
    summary: "get self marketplace telegram bot customers",
    responses: [ok: {"", "application/json", Schemas.MarketplaceTelegramBotCustomers}]
  )

  def index_self_customers(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        _params
      ) do
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    with values when is_list(values) <-
           Marketplaces.all_telegram_bot_customers(marketplace_account, opts) do
      Conn.ok(conn, MarketplaceTelegramBotCustomerJSON.render(values))
    end
  end

  operation(:show_self_customer,
    summary: "show self marketplace telegram bot customer",
    responses: [ok: {"", "application/json", Schemas.MarketplaceTelegramBotCustomer}]
  )

  def show_self_customer(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"customer_id" => customer_id}
      ) do
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    with customer_id when is_integer(customer_id) <- String.to_integer(customer_id),
         customer = %MarketplaceTelegramBotCustomer{} <-
           Marketplaces.get_telegram_bot_customer(marketplace_account, customer_id, opts) do
      Conn.ok(conn, MarketplaceTelegramBotCustomerJSON.render(customer))
    end
  end

  operation(:all_messages,
    parameters: [
      customer_id: [in: :path, type: :integer]
    ],
    responses: [
      ok: {"", "application/json", Schemas.MarketplaceTelegramBotCustomerMessages}
    ]
  )

  def all_messages(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"customer_id" => customer_id}
      ) do
    with customer_id when is_integer(customer_id) <- String.to_integer(customer_id),
         messages when is_list(messages) <-
           Marketplaces.all_telegram_bot_customer_messages(marketplace_account, customer_id) do
      Conn.ok(conn, MarketplaceTelegramBotCustomerMessageJSON.render(messages))
    end
  end

  operation(:create_message,
    request_body: {"", "application/json", Schemas.MarketplaceTelegramBotCustomerMessageCreate},
    responses: [
      ok: {"", "application/json", Schemas.MarketplaceTelegramBotCustomerMessage}
    ]
  )

  def create_message(%{assigns: %{marketplace_account: marketplace_account}} = conn, params) do
    {:ok, message} =
      Marketplaces.create_telegram_bot_customer_message(marketplace_account, params)

    bot = Marketplaces.get_telegram_bot(marketplace_account)
    customer = Marketplaces.get_telegram_bot_customer(message.customer_id, [])

    MarketBot.send_message(bot, text: message.text, chat_id: customer.chat_id)
    CustomerChannel.new_message(message)

    Conn.ok(conn)
  end
end
