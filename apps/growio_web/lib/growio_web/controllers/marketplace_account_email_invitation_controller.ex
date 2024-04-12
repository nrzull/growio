defmodule GrowioWeb.Controllers.MarketplaceAccountEmailInvitationController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceAccountRole
  alias Growio.Marketplaces.MarketplaceAccountEmailInvitation
  alias GrowioWeb.Views.MarketplaceAccountEmailInvitationJSON
  alias Growio.Repo

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_account_email_invitations"])

  operation(:index,
    summary: "show email invitations",
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountEmailInvitations}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _params) do
    with invitations when is_list(invitations) <-
           Marketplaces.all_account_email_invitations(marketplace_account) do
      invitations
      |> MarketplaceAccountEmailInvitationJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

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
      |> MarketplaceAccountEmailInvitationJSON.render()
      |> then(&Conn.ok(conn, &1))
    end
  end

  operation(:guest_show,
    summary: "get received email invitation",
    parameters: [
      email: [in: :path, description: "email", type: :string],
      password: [in: :path, description: "password", type: :string]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccountEmailInvitation}]
  )

  def guest_show(conn, %{"email" => email, "password" => password}) do
    with invitation = %MarketplaceAccountEmailInvitation{} <-
           Marketplaces.get_account_email_invitation(email, password),
         invitation <- Repo.preload(invitation, role: [:marketplace]) do
      Conn.ok(conn, MarketplaceAccountEmailInvitationJSON.render(invitation))
    end
  end

  operation(:guest_accept,
    summary: "accept received email invitation",
    parameters: [
      email: [in: :path, description: "email", type: :string],
      password: [in: :path, description: "password", type: :string]
    ],
    responses: [ok: ""]
  )

  def guest_accept(conn, %{"email" => email, "password" => password}) do
    with %MarketplaceAccountEmailInvitation{} <-
           Marketplaces.get_account_email_invitation(email, password),
         {:ok, _} = Marketplaces.use_account_email_invitation(password) do
      Conn.ok(conn)
    end
  end
end
