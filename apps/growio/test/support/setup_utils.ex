defmodule GrowioWeb.SetupUtils do
  use GrowioWeb.ConnCase
  alias Growio.Repo
  alias Growio.AccountsFixture
  alias Growio.Marketplaces.MarketplaceAccount

  def auth(%{conn: conn}) do
    email = AccountsFixture.gen_account_email()

    %{"password" => password} =
      conn
      |> post(~p"/api/auth/email", %{"email" => email})
      |> json_response(200)

    conn =
      conn
      |> post(~p"/api/auth/email/otp", %{"email" => email, "password" => password})
      |> recycle()
      |> Plug.Conn.put_req_header("content-type", "application/json")

    account = AccountsFixture.account!(email: email)

    {:ok, conn: conn, account: account}
  end

  def marketplace_account(%{conn: conn, account: account}) do
    conn =
      conn
      |> post(~p"/api/marketplaces", %{name: account.email})
      |> get(~p"/api/marketplace_accounts/self/active")

    %{"id" => id} = json_response(conn, 200)

    marketplace_account = Repo.get(MarketplaceAccount, id)

    conn =
      conn
      |> recycle()
      |> Plug.Conn.put_req_header("content-type", "application/json")

    {:ok, conn: conn, marketplace_account: marketplace_account}
  end
end
