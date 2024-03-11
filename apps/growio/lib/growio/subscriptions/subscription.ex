defmodule Growio.Subscriptions.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  @required ~w(name)a
  @optional ~w()a

  schema "subscriptions" do
    field(:name, :string)
    timestamps()
  end

  def changeset(%{} = params),
    do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:name)
  end
end
