defmodule GrowioWeb.Controllers.AccountController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.AccountJSON
  alias Growio.Accounts

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["accounts"])

  operation(:me,
    summary: "get self information",
    responses: [ok: {"", "application/json", Schemas.Account}]
  )

  def me(%{assigns: %{auth: %{account_id: account_id}}} = conn, _opts) do
    with account <- Accounts.get_account_by(:id, account_id) do
      Conn.ok(conn, AccountJSON.render(account))
    end
  end
end
