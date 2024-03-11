defmodule GrowioWeb.Controllers.FallbackController do
  use Phoenix.Controller
  alias Growio.Error

  def call(conn, {:error, error}) do
    conn
    |> put_status(400)
    |> put_view(json: MothershipWeb.Views.JSON)
    |> render(:error, %{errors: Error.prepare(error)})
  end

  def call(conn, {%Ecto.Changeset{}, _} = {changeset, _}) do
    conn
    |> put_status(400)
    |> put_view(json: MothershipWeb.Views.JSON)
    |> render(:error, %{errors: Error.prepare(changeset)})
  end

  def call(conn, opts) do
    conn
    |> put_status(500)
    |> put_view(json: MothershipWeb.Views.JSON)
    |> render(:error, %{errors: Error.prepare(opts)})
  end
end
