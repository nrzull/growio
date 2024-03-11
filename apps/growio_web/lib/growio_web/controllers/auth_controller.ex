defmodule GrowioWeb.Controllers.AuthController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Accounts

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["auth"])

  operation(:email,
    summary: "authenticate with email",
    request_body: {"", "application/json", Schemas.AuthRequest, required: true},
    responses: [ok: {"", "application/json", Schemas.AuthResponse}]
  )

  def email(conn, params) do
    with {:ok, account_email_confirmation} <- Accounts.create_account_email_confirmation(params),
         %{email: email, code: code} <- Map.from_struct(account_email_confirmation) do
      Conn.ok(conn, %{
        email: email,
        code: (Enum.member?([:dev, :test], Mix.env()) && code) || nil
      })
    end
  end

  operation(:email_confirmation,
    summary: "confirm authentication with email",
    request_body: {"", "application/json", Schemas.AuthEmailConfirmationRequest, required: true},
    responses: [ok: ""]
  )

  def email_confirmation(conn, _params) do
    Conn.ok(conn, "not implemented")
  end
end
