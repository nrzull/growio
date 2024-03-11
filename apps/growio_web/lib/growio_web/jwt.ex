defmodule GrowioWeb.JWT do
  alias Phoenix.Token
  alias GrowioWeb.Endpoint

  @jwt_secret Application.compile_env!(:growio_web, :jwt_secret)

  def encode_jwt(payload, max_age_in_seconds) when is_map(payload) do
    Token.sign(Endpoint, @jwt_secret, payload, max_age: max_age_in_seconds)
  end

  def decode_jwt(token, max_age_in_seconds) when is_bitstring(token) do
    Token.verify(Endpoint, @jwt_secret, token, max_age: max_age_in_seconds)
  end
end
