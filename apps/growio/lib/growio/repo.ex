defmodule Growio.Repo do
  use Ecto.Repo,
    otp_app: :growio,
    adapter: Ecto.Adapters.Postgres
end
