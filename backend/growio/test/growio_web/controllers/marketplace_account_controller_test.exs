defmodule GrowioWeb.Controllers.MarketplaceAccountControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.SetupUtils

  describe "GET /api/marketplace_accounts/self" do
    setup [{SetupUtils, :auth}]

    test "it should return self marketplace accounts", %{conn: conn, api_spec: api_spec} do
      conn
      |> get(~p"/api/marketplace_accounts/self")
      |> json_response(200)
      |> assert_schema("MarketplaceAccounts", api_spec)
    end
  end

  describe "GET /api/marketplace_accounts" do
    setup [{SetupUtils, :auth}, {SetupUtils, :marketplace_account}]

    test "it should return marketplace accounts of current active marketplace", %{
      conn: conn,
      api_spec: api_spec
    } do
      conn
      |> get(~p"/api/marketplace_accounts")
      |> json_response(200)
      |> assert_schema("MarketplaceAccounts", api_spec)
    end
  end
end
