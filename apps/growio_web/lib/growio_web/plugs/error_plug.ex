defmodule GrowioWeb.Plugs.ErrorPlug do
  alias OpenApiSpex.OpenApi

  @behaviour Plug

  @impl Plug
  def init(errors), do: errors

  @impl Plug
  def call(conn, errors) when is_list(errors) do
    errors =
      errors
      |> Enum.map(&Map.from_struct/1)
      |> Enum.reduce(%{}, fn %{name: name, reason: reason}, acc ->
        acc = Map.put_new(acc, name, [])
        Map.put(acc, name, Map.get(acc, name) ++ [Atom.to_string(reason)])
      end)

    response = OpenApi.json_encoder().encode!(%{errors: errors})

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(400, response)
  end
end
