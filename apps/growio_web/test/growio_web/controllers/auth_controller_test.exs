defmodule GrowioWeb.Controllers.AuthControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.Conn
  alias GrowioWeb.SetupUtils
  alias Growio.AccountsFixture

  @invalid_email "a"

  describe "POST /api/auth" do
    test "it should fail", %{conn: conn} do
      post(conn, ~p"/api/auth", %{email: @invalid_email})
      |> json_response(400)
    end

    test "it should success", %{conn: conn, api_spec: api_spec} do
      email = AccountsFixture.gen_account_email()

      post(conn, ~p"/api/auth", %{email: email})
      |> json_response(200)
      |> assert_schema("AuthResponse", api_spec)
    end
  end

  describe "POST /api/auth/confirm" do
    test "it should fail", %{conn: conn} do
      email = AccountsFixture.gen_account_email()

      %{"code" => code} =
        post(conn, ~p"/api/auth", %{email: email})
        |> json_response(200)

      post(conn, ~p"/api/auth/confirm", %{email: email, code: "123456"})
      |> json_response(400)

      post(conn, ~p"/api/auth/confirm", %{email: "qwe@gma.com", code: code})
      |> json_response(400)

      post(conn, ~p"/api/auth/confirm", %{email: "qwe@gma.com", code: "123456"})
      |> json_response(400)
    end

    test "it should success", %{conn: conn} do
      email = AccountsFixture.gen_account_email()

      %{"code" => code} =
        post(conn, ~p"/api/auth", %{email: email})
        |> json_response(200)

      post(conn, ~p"/api/auth/confirm", %{email: email, code: code})
      |> json_response(200)
    end
  end

  describe "GET /api/auth/healthcheck" do
    setup [{SetupUtils, :auth}]

    test "it should success", %{conn: conn} do
      get(conn, ~p"/api/auth/healthcheck") |> json_response(200)
    end

    test "it should fail without refresh cookie", %{conn: conn} do
      conn =
        delete_resp_cookie(conn, Conn.refresh_cookie_name(),
          same_site: "None",
          secure: true
        )
        |> recycle()

      get(conn, ~p"/api/auth/healthcheck") |> response(401)
    end

    test "it should fail without access cookie", %{conn: conn} do
      conn =
        delete_resp_cookie(conn, Conn.access_cookie_name(),
          same_site: "None",
          secure: true
        )
        |> recycle()

      get(conn, ~p"/api/auth/healthcheck") |> response(401)
    end

    test "it should success with expired access cookie and valid refresh cookie", %{
      conn: conn,
      account: account
    } do
      conn =
        Conn.setup_auth_cookies(conn, %{account_id: account.id}, access_token_max_age: 0)
        |> recycle()
        |> fetch_cookies()

      updated_conn =
        get(conn, ~p"/api/auth/healthcheck?access_token_max_age=0")

      response(updated_conn, 200)

      updated_conn = recycle(updated_conn) |> fetch_cookies()

      refute conn.req_cookies[Conn.access_cookie_name()] ===
               updated_conn.req_cookies[Conn.access_cookie_name()]

      refute conn.req_cookies[Conn.refresh_cookie_name()] ===
               updated_conn.req_cookies[Conn.refresh_cookie_name()]
    end
  end
end
