defmodule GrowioWeb.Controllers.MarketplaceAccountEmailInvitationControllerTest do
  use GrowioWeb.ConnCase
  alias GrowioWeb.SetupUtils
  alias Growio.MarketplacesFixture
  alias Growio.Repo

  describe "POST /api/marketplace_account_email_invitations" do
    setup [{SetupUtils, :auth}, {SetupUtils, :marketplace_account}]

    test "it should create email invitation", %{
      conn: conn,
      marketplace_account: marketplace_account,
      api_spec: api_spec
    } do
      marketplace_account = Repo.preload(marketplace_account, [:marketplace])
      role = MarketplacesFixture.role!(marketplace_account.marketplace)

      conn
      |> post(~p"/api/marketplace_account_email_invitations", %{
        email: "example@example.com",
        role_id: role.id
      })
      |> json_response(200)
      |> assert_schema("MarketplaceAccountEmailInvitation", api_spec)
    end
  end
end
