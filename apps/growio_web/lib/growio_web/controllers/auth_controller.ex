defmodule GrowioWeb.Controllers.AuthController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Accounts
  alias Growio.Accounts.Account
  alias Growio.Accounts.AccountEmailOTP

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["auth"])

  operation(:email,
    summary: "authenticate with email",
    request_body: {"", "application/json", Schemas.AuthEmailRequest, required: true},
    responses: [ok: {"", "application/json", Schemas.AuthEmailResponse}]
  )

  def email(conn, params) do
    with {:ok, account_email_otp} <- Accounts.create_account_email_otp(params),
         %{email: email, password: password} <- Map.from_struct(account_email_otp) do
      Conn.ok(conn, %{
        email: email,
        password: (Enum.member?([:dev, :test], Mix.env()) && password) || nil
      })
    end
  end

  operation(:email_otp,
    summary: "confirm authentication with email",
    request_body: {"", "application/json", Schemas.AuthEmailOTPRequest, required: true},
    responses: [ok: ""]
  )

  def email_otp(conn, %{"email" => input_email, "password" => input_password}) do
    with account_email_otp = %AccountEmailOTP{email: email, password: password} <-
           Accounts.get_active_account_email_otp(input_email),
         [true, true] <- [input_email == email, input_password == password],
         {:ok, _} <-
           Accounts.delete_account_email_otp(account_email_otp),
         {:ok, %Account{id: id}} <- Accounts.create_account(%{email: input_email}) do
      conn
      |> Conn.setup_auth_cookies(%{account_id: id})
      |> Conn.ok()
    else
      [_, _] -> Conn.bad_request(conn)
      nil -> Conn.bad_request(conn)
      error -> raise error
    end
  end

  operation(:healthcheck,
    summary: "check authentication health",
    responses: [ok: ""]
  )

  def healthcheck(conn, _params) do
    Conn.ok(conn)
  end
end
