defmodule GrowioWeb.Controllers.MarketplaceAccountControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.SetupUtils

  describe "GET /api/marketplace_accounts/self" do
    setup [{SetupUtils, :auth}]

    test "it should return self marketplace accounts", %{conn: conn, api_spec: api_spec} do
      result =
        conn
        |> get(~p"/api/marketplace_accounts/self")
        |> json_response(200)

      assert_schema(result, "MarketplaceAccounts", api_spec)
    end
  end
end
