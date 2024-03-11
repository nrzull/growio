defmodule GrowioWeb.SetupUtils do
  use GrowioWeb.ConnCase
  alias Growio.AccountsFixture

  def auth(%{conn: conn}) do
    email = AccountsFixture.gen_account_email()

    %{"code" => code} =
      conn
      |> post(~p"/api/auth", %{"email" => email})
      |> json_response(200)

    conn =
      conn
      |> post(~p"/api/auth/confirm", %{"email" => email, "code" => code})
      |> recycle()
      |> Plug.Conn.put_req_header("content-type", "application/json")

    account = AccountsFixture.account!(email: email)

    {:ok, conn: conn, account: account}
  end
end
