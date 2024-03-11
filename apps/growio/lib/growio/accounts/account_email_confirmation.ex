defmodule Growio.Accounts.AccountEmailConfirmation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Accounts.Account
  alias Growio.Utils

  @type t :: %__MODULE__{}
  @required ~w(email)a
  @optional ~w(used code expired_at)a

  schema "account_email_confirmations" do
    field(:email, :string)
    field(:code, :string)
    field(:used, :boolean)
    field(:expired_at, :naive_datetime)
    timestamps()
  end

  def insert_changeset(%{} = params),
    do: insert_changeset(%__MODULE__{}, params)

  def insert_changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> Account.validate_email()
    |> put_change(:code, generate_code())
    |> put_change(:expired_at, generate_expired_at())
  end

  def update_changeset(%__MODULE__{} = struct, %{} = params) do
    struct
    |> cast(params, [:used])
    |> validate_required([:used])
  end

  def validate_code(changeset) do
    changeset
    |> validate_length(:code, is: 6)
    |> validate_format(:code, ~r/^[0-9]{6}$/)
  end

  def generate_code() do
    Utils.gen_integer(1..6) |> Integer.to_string()
  end

  def generate_expired_at() do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(5, :minute)
    |> NaiveDateTime.truncate(:second)
  end
end
