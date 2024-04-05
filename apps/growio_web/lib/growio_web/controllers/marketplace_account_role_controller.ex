defmodule GrowioWeb.Controllers.MarketplaceAccountRoleController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceAccountRoleJSON
  alias Growio.Marketplaces

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_account_roles"])

  operation(:index,
    summary: "show marketplace account roles",
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountRoles}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    with roles when is_list(roles) <- Marketplaces.all_account_roles(marketplace_account) do
      roles
      |> MarketplaceAccountRoleJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:create,
    summary: "create marketplace account role",
    request_body: {"", "application/json", Schemas.MarketplaceAccountRoleCreate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountRole}]
  )

  def create(%{assigns: %{marketplace_account: marketplace_account}} = conn, params) do
    with {:ok, role} <- Marketplaces.create_account_role(marketplace_account, params) do
      role
      |> MarketplaceAccountRoleJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end
end
