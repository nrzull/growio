defmodule Growio.Subscriptions do
  alias Growio.Repo
  alias Growio.Subscriptions.Subscription

  def default_subscription_name, do: "default"

  def create_subscription(%{} = params) do
    Subscription.changeset(params)
    |> Repo.insert()
  end

  def get_default_subscription() do
    Repo.get_by(Subscription, name: default_subscription_name())
  end
end
