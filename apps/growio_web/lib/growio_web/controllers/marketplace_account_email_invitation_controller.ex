defmodule GrowioWeb.Controllers.MarketplaceAccountEmailInvitationController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias GrowioWeb.Views.MarketplaceAccountEmailInvitationJson

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_account_email_invitations"])

  operation(:create,
    summary: "create email invitation",
    request_body:
      {"", "application/json", Schemas.MarketplaceAccountEmailInvitationCreateRequest,
       required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountEmailInvitation}]
  )

  def create(%{assigns: %{marketplace_account: marketplace_account}} = conn, %{
        "role_id" => marketplace_account_role_id,
        "email" => email
      }) do
    with role = %MarketplaceAccountRole{} <-
           Marketplaces.get_account_role(marketplace_account, marketplace_account_role_id),
         {:ok, invitation} <-
           Marketplaces.create_account_email_invitation(marketplace_account, role, %{email: email}) do
      invitation
      |> MarketplaceAccountEmailInvitationJson.render()
      |> then(&Conn.ok(conn, &1))
    end
  end
end
