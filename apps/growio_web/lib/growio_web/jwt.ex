defmodule GrowioWeb.Jwt do
  alias Phoenix.Token
  alias MothershipWeb.Endpoint

  @jwt_max_age_in_seconds 3600
  @jwt_secret Application.compile_env!(:growio_web, :jwt_secret)

  def access_token_name, do: "growio-access-token"

  def encode_jwt(payload, max_age \\ @jwt_max_age_in_seconds) when is_map(payload) do
    Token.sign(Endpoint, @jwt_secret, payload, max_age: max_age)
  end

  def decode_jwt(token, max_age \\ @jwt_max_age_in_seconds) when is_bitstring(token) do
    Token.verify(Endpoint, @jwt_secret, token, max_age: max_age)
  end
end
