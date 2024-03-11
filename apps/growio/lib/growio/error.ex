defmodule Growio.Error do
  def extract_from_changeset(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def prepare(param) do
    case param do
      %Ecto.Changeset{} = error -> extract_from_changeset(error)
      error when is_bitstring(error) -> %{detail: [error]}
      error when is_list(error) -> %{detail: error}
      error -> error
    end
  end
end
