defmodule Growio.Seeds do
  alias Growio.Repo
  alias Growio.Permissions.Definitions
  alias Growio.Permissions.Permission

  def start() do
    for {fun, _} <- Definitions.__info__(:functions) do
      value = apply(Definitions, fun, [])
      Repo.insert(Permission.changeset(%{name: value}))
    end
  end
end

Growio.Seeds.start()
