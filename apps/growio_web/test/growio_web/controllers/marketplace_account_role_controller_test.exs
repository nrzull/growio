defmodule GrowioWeb.Controllers.MarketplaceAccountRoleControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.SetupUtils
  alias Growio.Repo

  describe "GET /api/marketplace_account_roles" do
    setup [{SetupUtils, :auth}, {SetupUtils, :marketplace_account}]

    test "it should return account roles", %{conn: conn, api_spec: api_spec} do
      conn
      |> get(~p"/api/marketplace_account_roles")
      |> json_response(200)
      |> assert_schema("MarketplaceAccountRoles", api_spec)
    end
  end

  describe "PATCH /api/marketplace_account_roles/:id" do
    setup [{SetupUtils, :auth}, {SetupUtils, :marketplace_account}]

    test "it should update account role", %{
      conn: conn,
      api_spec: api_spec,
      marketplace_account: marketplace_account
    } do
      marketplace_account = Repo.preload(marketplace_account, [:role])

      conn
      |> patch(~p"/api/marketplace_account_roles/#{marketplace_account.role.id}", %{
        "name" => "qweqweqwe"
      })
      |> json_response(200)
      |> assert_schema("MarketplaceAccountRole", api_spec)
    end
  end
end
