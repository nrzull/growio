defmodule GrowioWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  alias GrowioWeb.{Router, Endpoint}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [Server.from_endpoint(Endpoint)],
      info: %Info{title: "Growio API", version: "1.0"},
      paths: Paths.from_router(Router)
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
