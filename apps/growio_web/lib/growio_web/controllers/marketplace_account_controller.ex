defmodule GrowioWeb.Controllers.MarketplaceAccountController do
  use GrowioWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias GrowioWeb.Conn
  alias GrowioWeb.Schemas
  alias GrowioWeb.Views.MarketplaceAccountJSON
  alias Growio.Marketplaces
  alias Growio.Repo
  alias Growio.Marketplaces.MarketplaceAccount

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
    opts = GrowioWeb.QueryParams.into_keyword(conn.query_params)

    marketplace_account
    |> Marketplaces.all_accounts(opts)
    |> Enum.map(&Repo.preload(&1, [:marketplace, :role, :account]))
    |> MarketplaceAccountJSON.render()
    |> then(&Conn.ok(conn, &1))
  end

  operation(:update,
    summary: "update marketplace account",
    parameters: [
      id: [in: :path, description: "id", type: :integer]
    ],
    request_body: {"", "application/json", Schemas.MakretplaceAccountUpdate, required: true},
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccount}]
  )

  def update(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id} = params
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         target_account = %MarketplaceAccount{} <-
           Marketplaces.get_account(marketplace_account, id),
         {:ok, updated_account} <-
           Marketplaces.update_account(marketplace_account, target_account, params),
         updated_account = Repo.preload(updated_account, [:marketplace, :role, :account]) do
      Conn.ok(conn, MarketplaceAccountJSON.render(updated_account))
    end
  end

  operation(:delete,
    summary: "delete marketplace account",
    parameters: [
      id: [in: :path, description: "id", type: :integer]
    ],
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccount}]
  )

  def delete(
        %{assigns: %{marketplace_account: marketplace_account}} = conn,
        %{"id" => id}
      ) do
    with id when is_integer(id) <- String.to_integer(id),
         target_account = %MarketplaceAccount{} <-
           Marketplaces.get_account(marketplace_account, id),
         {:ok, deleted_account} <- Marketplaces.block_account(marketplace_account, target_account) do
      Conn.ok(conn, MarketplaceAccountJSON.render(deleted_account))
    end
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
      Marketplaces.all_accounts(account, blocked_at: false)
      |> List.first()
      |> case do
        %MarketplaceAccount{} = marketplace_account ->
          value =
            marketplace_account
            |> Repo.preload([:marketplace, :role])
            |> MarketplaceAccountJSON.render()

          conn
          |> Conn.set_active_marketplace_account_id(value.id)
          |> Conn.ok(value)

        _ ->
          Conn.unauthorized(conn)
      end
    end

    case active_marketplace_account_id do
      nil ->
        setup_initial_account.()

      _ ->
        marketplace_account = Marketplaces.get_account(account, active_marketplace_account_id)

        cond do
          is_nil(marketplace_account) ->
            setup_initial_account.()

          Marketplaces.blocked_account?(marketplace_account) ->
            setup_initial_account.()

          true ->
            marketplace_account
            |> Repo.preload([:marketplace, :role])
            |> MarketplaceAccountJSON.render()
            |> then(&Conn.ok(conn, &1))
        end
    end
  end

  operation(:update_self_active,
    summary: "update self active marketplace account",
    responses: [ok: {"", "application/json", Schemas.MarketplaceAccount}]
  )

  def update_self_active(%{assigns: %{account: account}} = conn, %{"id" => id}) do
    with id when is_integer(id) <- String.to_integer(id),
         marketplace_account = %MarketplaceAccount{} <- Marketplaces.get_account(account, id),
         false <- Marketplaces.blocked_account?(marketplace_account) do
      value =
        marketplace_account
        |> Repo.preload([:marketplace, :role])
        |> MarketplaceAccountJSON.render()

      conn
      |> Conn.set_active_marketplace_account_id(value.id)
      |> Conn.ok(value)
    end
  end
end
