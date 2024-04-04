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

  operation(:index,
    summary: "get marketplace accounts",
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccounts}]
  )

  def index(%{assigns: %{marketplace_account: marketplace_account}} = conn, _opts) do
    marketplace_account
    |> Marketplaces.all_accounts()
    |> Enum.map(&Repo.preload(&1, [:marketplace, :role, :account]))
    |> MarketplaceAccountJSON.render()
    |> then(&Conn.ok(conn, &1))
  end

  operation(:self,
    summary: "get self marketplace accounts",
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccounts}]
  )

  def self(%{assigns: %{account: account}} = conn, _opts) do
    account
    |> Marketplaces.all_accounts()
    |> Enum.map(&Repo.preload(&1, [:marketplace, :role]))
    |> MarketplaceAccountJSON.render()
    |> then(&Conn.ok(conn, &1))
  end

  operation(:self_active,
    summary: "get self active marketplace account",
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccount}]
  )

  def self_active(%{assigns: %{account: account}} = conn, _opts) do
    active_marketplace_account_id = Conn.get_active_marketplace_account_id(conn)

    setup_initial_account = fn ->
      value =
        account
        |> Marketplaces.all_accounts()
        |> List.first()
        |> Repo.preload([:marketplace, :role])
        |> MarketplaceAccountJSON.render()

      conn
      |> Conn.set_active_marketplace_account_id(value.id)
      |> Conn.ok(value)
    end

    case active_marketplace_account_id do
      nil ->
        setup_initial_account.()

      _ ->
        case Marketplaces.get_account(account, active_marketplace_account_id) do
          nil ->
            setup_initial_account.()

          account ->
            account
            |> Repo.preload([:marketplace, :role])
            |> MarketplaceAccountJSON.render()
            |> then(&Conn.ok(conn, &1))
        end
    end
  end
end
