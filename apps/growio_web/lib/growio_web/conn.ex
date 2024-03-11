defmodule GrowioWeb.Conn do
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [render: 3, put_view: 2]
  alias GrowioWeb.Views.JSON
  alias Growio.Error

  def ok(conn, payload \\ nil) do
    conn
    |> put_status(200)
    |> put_view(json: GrowioWeb.Views.JSON)
    |> render(:ok, %{payload: payload})
  end

  def bad_request(conn, errors \\ ["bad request"]) do
    conn
    |> put_status(400)
    |> put_view(json: JSON)
    |> render(:error, %{errors: Error.prepare(errors)})
  end
end
