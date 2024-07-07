defmodule Growio.Accounts.AccountEmailOTP do
  use Ecto.Schema
  import Ecto.Changeset
  alias Growio.Accounts.Account
  alias Growio.Utils

  @type t :: %__MODULE__{}
  @required ~w(email)a
  @optional ~w()a

  schema "account_email_otp" do
    field(:email, :string)
    field(:password, :string)
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
    |> put_change(:password, generate_password())
    |> put_change(:expired_at, generate_expired_at())
  end

  defp generate_password() do
    Utils.gen_integer(1..6) |> Integer.to_string()
  end

  defp generate_expired_at() do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(5, :minute)
    |> NaiveDateTime.truncate(:second)
  end
end
