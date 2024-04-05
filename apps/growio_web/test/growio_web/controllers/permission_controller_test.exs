defmodule GrowioWeb.Controllers.PermissionControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.SetupUtils

  describe "GET /api/permissions" do
    setup [{SetupUtils, :auth}]

    test "it should get all available permissions", %{conn: conn, api_spec: api_spec} do
      result =
        conn
        |> get(~p"/api/permissions")
        |> json_response(200)

      assert_schema(result, "Permissions", api_spec)
    end
  end
end
