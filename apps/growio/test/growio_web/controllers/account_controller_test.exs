defmodule GrowioWeb.Controllers.AccountControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.SetupUtils

  describe "GET /api/accounts/self" do
    setup [{SetupUtils, :auth}]

    test "it should return self account info", %{conn: conn, account: account, api_spec: api_spec} do
      result =
        conn
        |> get(~p"/api/accounts/self")
        |> json_response(200)

      assert_schema(result, "Account", api_spec)
      assert account.id == result["id"]
    end
  end
end
