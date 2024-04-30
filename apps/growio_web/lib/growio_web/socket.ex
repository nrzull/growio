defmodule GrowioWeb.Socket do
  use Phoenix.Socket
  alias GrowioWeb.Plugs.AuthPlug

  channel("customer:*", GrowioWeb.Channels.CustomerChannel)

  def connect(%{"ws_token" => ws_token}, socket) do
    ws_secret = Application.fetch_env!(:growio_web, :ws_secret)

    with {:ok, [access_cookie, refresh_cookie]} <-
           Plug.Crypto.decrypt(ws_secret, "ws_token", ws_token),
         {:ok, %{account: account}} <- AuthPlug.handle_cookies(access_cookie, refresh_cookie) do
      {:ok, assign(socket, %{account: account})}
    else
      _ -> {:error, :unauthorized}
    end
  end

  def id(_socket) do
    nil
  end
end
