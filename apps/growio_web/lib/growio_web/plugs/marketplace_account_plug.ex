defmodule GrowioWeb.Plugs.MarketplaceAccountPlug do
  import Plug.Conn
  alias Growio.Marketplaces
  alias Growio.Marketplaces.MarketplaceAccount

  @behaviour Plug

  @impl Plug
  def init(params), do: params

  @impl Plug
  def call(%{assigns: %{account: account}} = conn, _opts) do
    with id when is_integer(id) <- GrowioWeb.Conn.get_active_marketplace_account_id(conn),
         marketplace_account = %MarketplaceAccount{} <- Marketplaces.get_account(account, id) do
      assign(conn, :marketplace_account, marketplace_account)
    else
      _ -> GrowioWeb.Conn.unauthorized(conn)
    end
  end
end
