defmodule GrowioWeb.Controllers.MarketplaceAccountRoleControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.SetupUtils

  describe "GET /api/marketplace_account_roles" do
    setup [{SetupUtils, :auth}, {SetupUtils, :marketplace_account}]

    test "it should return account roles", %{conn: conn, api_spec: api_spec} do
      conn
      |> get(~p"/api/marketplace_account_roles")
      |> json_response(200)
      |> assert_schema("MarketplaceAccountRoles", api_spec)
    end
  end
end
