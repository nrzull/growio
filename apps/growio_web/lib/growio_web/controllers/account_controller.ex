defmodule GrowioWeb.Controllers.AccountController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.AccountJSON

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["accounts"])

  operation(:self,
    summary: "get self information",
    responses: [ok: {"", "application/json", Schemas.Account}]
  )

  def self(%{assigns: %{account: account}} = conn, _opts) do
    Conn.ok(conn, AccountJSON.render(account))
  end
end
