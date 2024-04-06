defmodule GrowioWeb.Controllers.MarketplaceAccountRoleController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces.MarketplaceAccountRole
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
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    with roles when is_list(roles) <- Marketplaces.all_account_roles(marketplace_account, opts) do
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

  operation(:update,
    summary: "update marketplace account role",
    parameters: [
      id: [in: :path, description: "role id", type: :integer, example: 1]
    ],
    request_body: {"", "application/json", Schemas.MarketplaceAccountRoleUpdate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountRole}]
  )

  def update(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id} = params
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         role = %MarketplaceAccountRole{} <-
           Marketplaces.get_account_role(marketplace_account, id),
         {:ok, updated_role} <-
           Marketplaces.update_account_role(marketplace_account, role, params) do
      Conn.ok(conn, MarketplaceAccountRoleJSON.render(updated_role))
    end
  end

  operation(:delete,
    summary: "delete marketplace account role",
    parameters: [
      id: [in: :path, description: "role id", type: :integer, example: 1]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountRole}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id}
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         role = %MarketplaceAccountRole{} <-
           Marketplaces.get_account_role(marketplace_account, id),
         {:ok, deleted_role} <- Marketplaces.delete_account_role(marketplace_account, role) do
      Conn.ok(conn, MarketplaceAccountRoleJSON.render(deleted_role))
    end
  end
end
