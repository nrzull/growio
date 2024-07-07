defmodule GrowioWeb.Controllers.MarketplaceControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.SetupUtils

  describe "POST /api/marketplaces" do
    setup [{SetupUtils, :auth}]

    test "it should create marketplace", %{conn: conn, api_spec: api_spec} do
      result =
        conn
        |> post(~p"/api/marketplaces", %{name: "marketplace"})
        |> json_response(200)

      assert_schema(result, "Marketplace", api_spec)
    end
  end
end
