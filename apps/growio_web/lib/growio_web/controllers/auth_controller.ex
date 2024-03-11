defmodule GrowioWeb.Controllers.AuthController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.JWT
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Accounts
  alias Growio.Accounts.Account
  alias Growio.Accounts.AccountEmailConfirmation

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

  def email_confirmation(conn, %{"email" => input_email, "code" => input_code}) do
    with account_email_confirmation = %AccountEmailConfirmation{email: email, code: code} <-
           Accounts.get_active_account_email_confirmation(input_email),
         [true, true] <- [input_email == email, input_code == code],
         {:ok, _} <-
           Accounts.update_account_email_confirmation(account_email_confirmation, %{used: true}),
         {:ok, %Account{id: id}} <- Accounts.create_account(%{email: input_email}) do
      token = JWT.encode_jwt(%{account_id: id})

      put_resp_cookie(conn, JWT.access_token_name(), token,
        domain: Map.get(conn, :host),
        path: "/",
        http_only: true,
        same_site: "None",
        secure: true
      )
      |> Conn.ok()
    else
      [_, _] -> Conn.bad_request(conn)
      nil -> Conn.bad_request(conn)
      error -> raise error
    end
  end
end
