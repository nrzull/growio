defmodule GrowioWeb.Controllers.AuthController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["auth"])

  operation(:email,
    summary: "authenticate with email",
    request_body: {"", "application/json", Schemas.AuthRequest, required: true},
    responses: [ok: ""]
  )

  def email(conn, _params) do
    Conn.ok(conn, "not implemented")
  end
end
