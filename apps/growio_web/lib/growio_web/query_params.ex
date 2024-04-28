defmodule GrowioWeb.QueryParams do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(deleted_at blocked_at filters)a

  embedded_schema do
    field(:deleted_at, :boolean)
    field(:blocked_at, :boolean)
    field(:filters, :map)
  end

  def into_keyword(%{} = params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> then(fn changeset -> changeset.changes end)
    |> Enum.map(fn {k, v} -> Keyword.new([{k, v}]) end)
    |> Enum.reduce(Keyword.new([]), fn v, acc -> Keyword.merge(acc, v) end)
  end
end
