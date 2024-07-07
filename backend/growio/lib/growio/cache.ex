defmodule Growio.Cache do
  use Nebulex.Cache,
    otp_app: :growio,
    adapter: Nebulex.Adapters.Local
end
