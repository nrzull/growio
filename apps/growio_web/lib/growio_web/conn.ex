defmodule GrowioWeb.Conn do
  import Plug.Conn,
    only: [
      put_status: 2,
      put_resp_cookie: 4,
      send_resp: 3,
      halt: 1,
      delete_resp_cookie: 3
    ]

  import Phoenix.Controller, only: [render: 3, put_view: 2]

  alias Growio.Cache
  alias GrowioWeb.Views.JSON
  alias Growio.Error
  alias GrowioWeb.JWT

  def access_cookie_name, do: "growio-access-token"
  def access_token_max_age, do: 60

  def refresh_cookie_name, do: "growio-refresh-token"
  def refresh_token_max_age, do: 60 * 60 * 24
  def refresh_token_cache_ttl, do: :timer.hours(48)

  def ok(conn, payload \\ nil) do
    conn
    |> put_status(200)
    |> put_view(json: GrowioWeb.Views.JSON)
    |> render(:ok, %{payload: payload})
  end

  def bad_request(conn, errors \\ ["bad request"]) do
    conn
    |> put_status(400)
    |> put_view(json: JSON)
    |> render(:error, %{errors: Error.prepare(errors)})
  end

  def unauthorized(conn) do
    conn
    |> send_resp(401, "")
    |> halt()
  end

  def setup_auth_cookies(conn, %{} = params, opts \\ []) do
    access_token_age = Keyword.get(opts, :access_token_max_age, access_token_max_age())

    access_token = JWT.encode_jwt(params, access_token_age)

    refresh_token_age = Keyword.get(opts, :refresh_token_max_age, refresh_token_max_age())

    refresh_token =
      JWT.encode_jwt(%{access_token: access_token}, refresh_token_age)

    conn
    |> put_access_cookie(access_token)
    |> put_refresh_cookie(refresh_token)
  end

  def delete_auth_cookies(conn) do
    conn
    |> delete_resp_cookie(access_cookie_name(),
      same_site: "None",
      secure: true
    )
    |> delete_resp_cookie(refresh_cookie_name(),
      same_site: "None",
      secure: true
    )
  end

  defp put_access_cookie(conn, token) do
    conn
    |> put_resp_cookie(access_cookie_name(), token,
      domain: Map.get(conn, :host),
      path: "/",
      http_only: true,
      same_site: "None",
      secure: true
    )
  end

  defp put_refresh_cookie(conn, token) do
    conn
    |> put_resp_cookie(refresh_cookie_name(), token,
      domain: Map.get(conn, :host),
      path: "/",
      http_only: true,
      same_site: "None",
      secure: true
    )
  end

  def invalidated_refresh_cookie?(name) do
    not is_nil(Cache.get("refresh_cookie_#{name}"))
  end

  def invalidate_refresh_cookie(name) do
    if invalidated_refresh_cookie?(name) do
      {:ok, true}
    else
      Cache.put("refresh_cookie_#{name}", true, ttl: refresh_token_cache_ttl())
    end
  end
end
