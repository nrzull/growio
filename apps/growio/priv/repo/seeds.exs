defmodule Growio.Seeds do
  alias Growio.Repo
  alias Growio.Permissions
  alias Growio.Permissions.Permission

  def start() do
    for name <- Permissions.definitions() do
      Repo.insert(Permission.changeset(%{name: name}))
    end
  end
end

Growio.Seeds.start()
