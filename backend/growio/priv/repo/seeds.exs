defmodule Growio.Seeds do
  alias Growio.Repo
  alias Growio.Permissions
  alias Growio.Permissions.Permission
  alias Growio.Subscriptions

  def start() do
    seed_permissions()
    seed_subscriptions()
  end

  def seed_permissions() do
    for name <- Permissions.definitions() do
      Repo.insert(Permission.changeset(%{name: name}))
    end
  end

  def seed_subscriptions() do
    Subscriptions.create_subscription(%{
      name: Subscriptions.default_subscription_name()
    })
  end
end

Growio.Seeds.start()
