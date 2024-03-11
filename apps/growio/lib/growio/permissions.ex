defmodule Growio.Permissions do
  alias Growio.Repo
  alias Growio.Permissions.Permission
  alias Growio.Permissions.PermissionDefs

  @all_cache_ttl :timer.minutes(10)

  def definitions do
    PermissionDefs.__info__(:functions)
    |> Enum.map(fn {name, _} ->
      apply(PermissionDefs, name, [])
    end)
  end

  def all(opts \\ []) do
    repo = Keyword.get(opts, :repo, Repo)

    case Cachex.get(Growio.Cache, "Growio.Permissions.all") do
      {:ok, values} when is_list(values) ->
        values

      _ ->
        values =
          Enum.map(definitions(), fn name ->
            repo.get_by(Permission, name: name)
          end)

        Cachex.put(Growio.Cache, "Growio.Permissions.all", values, ttl: @all_cache_ttl)

        values
    end
  end
end
