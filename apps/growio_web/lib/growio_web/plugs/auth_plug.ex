defmodule GrowioWeb.Plugs.AuthPlug do
  import Plug.Conn
  alias GrowioWeb.Conn
  alias GrowioWeb.JWT

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

    with {:has_pair, [true, true]} <-
           {:has_pair, [is_bitstring(access_cookie), is_bitstring(refresh_cookie)]},
         {:decode_refresh, {:ok, decoded_refresh_token}} <-
           {:decode_refresh, JWT.decode_jwt(refresh_cookie, refresh_token_age)},
         {:decode_access, {:ok, decoded_access_token}} <-
           {:decode_access, JWT.decode_jwt(access_cookie, access_token_age)},
         {:valid_pair, true} <-
           {:valid_pair, Map.get(decoded_refresh_token, :access_token) == access_cookie} do
      assign(conn, :auth, decoded_access_token)
    else
      {:decode_access, {:error, :expired}} ->
        {:ok, decoded_refresh} = JWT.decode_jwt(refresh_cookie, 999_999_999)
        {:ok, decoded_access} = JWT.decode_jwt(access_cookie, 999_999_999)

        if decoded_refresh.access_token == access_cookie do
          conn
          |> Conn.setup_auth_cookies(decoded_access)
          |> assign(:auth, decoded_access)
        else
          Conn.unauthorized(conn)
        end

      _ ->
        Conn.unauthorized(conn)
    end
  end
end
