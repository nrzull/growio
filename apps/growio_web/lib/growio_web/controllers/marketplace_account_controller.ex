defmodule GrowioWeb.Controllers.MarketplaceAccountController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceAccountJSON
  alias Growio.Marketplaces
  alias Growio.Repo

  plug(OpenApiSpex.Plug.CastAndValidate,
    render_error: GrowioWeb.Plugs.ErrorPlug,
    replace_params: false
  )

  action_fallback(GrowioWeb.Controllers.FallbackController)

  tags(["marketplace_accounts"])

  operation(:self,
    summary: "get self marketplace accounts",
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccounts}]
  )

  def self(%{assigns: %{account: account}} = conn, _opts) do
    values =
      account
      |> Marketplaces.all_accounts()
      |> Enum.map(&Repo.preload(&1, [:marketplace, :role]))
      |> MarketplaceAccountJSON.render()

    Conn.ok(conn, values)
  end
end
