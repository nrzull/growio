defmodule GrowioWeb.Plugs.AuthPlug do
  import Plug.Conn
  alias GrowioWeb.Conn
  alias GrowioWeb.JWT
  alias Growio.Accounts
  alias Growio.Accounts.Account

  @behaviour Plug

  @impl Plug
  def init(params), do: params

  @impl Plug
  def call(conn, opts) do
    conn =
      conn
      |> fetch_cookies()
      |> fetch_query_params(opts)

    access_cookie = conn.req_cookies[Conn.access_cookie_name()]
    refresh_cookie = conn.req_cookies[Conn.refresh_cookie_name()]

    access_token_age =
      (Mix.env() == :test &&
         Map.get(conn.query_params, "access_token_max_age")) ||
        Conn.access_token_max_age()

    access_token_age =
      (is_bitstring(access_token_age) && String.to_integer(access_token_age)) || access_token_age

    refresh_token_age =
      (Mix.env() == :test &&
         Map.get(conn.query_params, "refresh_token_max_age")) ||
        Conn.refresh_token_max_age()

    refresh_token_age =
      (is_bitstring(refresh_token_age) && String.to_integer(refresh_token_age)) ||
        refresh_token_age

    with [true, true] <-
           [is_bitstring(access_cookie), is_bitstring(refresh_cookie)],
         false <- Conn.invalidated_refresh_cookie?(refresh_cookie),
         {:ok, decoded_refresh_token} <- JWT.decode_jwt(refresh_cookie, refresh_token_age),
         {:decode_access, {:ok, decoded_access_token}} <-
           {:decode_access, JWT.decode_jwt(access_cookie, access_token_age)},
         true <- Map.get(decoded_refresh_token, :access_token) == access_cookie,
         %{account_id: account_id} <- decoded_access_token,
         account = %Account{} <- Accounts.get_account_by(:id, account_id) do
      ok(conn, account)
    else
      {:decode_access, {:error, :expired}} ->
        max_age = 999_999_999

        with {:ok, decoded_refresh} <- JWT.decode_jwt(refresh_cookie, max_age),
             {:ok, decoded_access} <- JWT.decode_jwt(access_cookie, max_age),
             true <- decoded_refresh.access_token == access_cookie,
             %{account_id: account_id} <- decoded_access,
             account = %Account{} <- Accounts.get_account_by(:id, account_id) do
          conn
          |> Conn.setup_auth_cookies(decoded_access)
          |> ok(account)
        else
          _ ->
            Conn.unauthorized(conn)
        end

      _ ->
        Conn.invalidate_refresh_cookie(refresh_cookie)
        Conn.unauthorized(conn)
    end
  end

  defp ok(conn, %Account{} = account) do
    assign(conn, :account, account)
  end
end
