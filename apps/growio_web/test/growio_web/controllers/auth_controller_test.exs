defmodule GrowioWeb.Controllers.AuthControllerTest do
  use GrowioWeb.ConnCase
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
end
