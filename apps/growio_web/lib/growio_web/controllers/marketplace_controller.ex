defmodule GrowioWeb.Controllers.MarketplaceController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias Growio.Marketplaces
  alias GrowioWeb.Conn
  alias GrowioWeb.Views.MarketplaceJSON
  alias GrowioWeb.Schemas

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
end
