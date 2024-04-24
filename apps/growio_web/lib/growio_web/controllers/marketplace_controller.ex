defmodule GrowioWeb.Controllers.MarketplaceController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias Growio.Marketplaces
  alias GrowioWeb.Conn
  alias GrowioWeb.Views.MarketplaceJSON
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces.Marketplace
  alias GrowioWeb.Views.MarketplaceOrderJSON
  alias GrowioWeb.Views.MarketplaceTelegramBotJSON

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplaces"])

  operation(:create,
    summary: "create marketplace",
    request_body: {"", "application/json", Schemas.MarketplaceCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.Marketplace}]
  )

  def create(%{assigns: %{account: account}} = conn, params) do
    with {:ok, %{marketplace: marketplace}} <- Marketplaces.create_marketplace(account, params) do
      Conn.ok(conn, MarketplaceJSON.render(marketplace))
    end
  end

  operation(:self_update,
    summary: "update marketplace",
    request_body: {"", "application/json", Schemas.Marketplace, required: true},
    responses: [ok: {"", "application/json", Schemas.Marketplace}]
  )

  def self_update(%{assigns: %{marketplace_account: marketplace_account}} = conn, params) do
    with {:ok, updated_marketplace} <-
           Marketplaces.update_marketplace(marketplace_account, params) do
      Conn.ok(conn, MarketplaceJSON.render(updated_marketplace))
    end
  end

  operation(:orders_index,
    summary: "show marketplace orders",
    responses: [ok: {"", "application/json", Schemas.MarketplaceOrders}]
  )

  def orders_index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    with orders when is_list(orders) <- Marketplaces.all_orders(marketplace_account) do
      Conn.ok(conn, MarketplaceOrderJSON.render(orders))
    end
  end

  operation(:integrations,
    summary: "get all marketplace integrations",
    responses: [ok: ""]
  )

  def integrations(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        _params
      ) do
    %Marketplace{id: marketplace_account.marketplace_id}
    |> Marketplaces.all_integrations()
    |> MarketplaceTelegramBotJSON.render()
    |> then(&Conn.ok(conn, &1))
  end
end
