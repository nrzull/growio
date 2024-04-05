defmodule GrowioWeb.Controllers.PermissionController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias Growio.Permissions
  alias GrowioWeb.Conn
  alias GrowioWeb.Views.PermissionJSON
  alias GrowioWeb.Schemas

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["permissions"])

  operation(:index,
    summary: "get permissions",
    responses: [ok: {"", "application/json", Schemas.Permissions}]
  )

  def index(conn, _params) do
    Conn.ok(conn, PermissionJSON.render(Permissions.definitions()))
  end
end
