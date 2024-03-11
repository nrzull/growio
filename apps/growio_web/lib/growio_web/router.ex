defmodule GrowioWeb.Router do
  use GrowioWeb, :router
  alias GrowioWeb.Controllers.AuthController

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: GrowioWeb.ApiSpec)
  end

  scope "/api" do
    pipe_through(:api)
    post("/auth", AuthController, :email)
    post("/auth/confirm", AuthController, :email_confirmation)
  end

  if Application.compile_env(:growio_web, :dev_routes) do
    scope "/dev" do
      pipe_through([:fetch_session, :protect_from_forgery])
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  if Application.compile_env(:growio_web, :swaggerui_routes) do
    scope "/swaggerui" do
      pipe_through(:browser)
      get("/", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi")
    end

    scope "/api" do
      pipe_through(:api)
      get("/openapi", OpenApiSpex.Plug.RenderSpec, [])
    end
  end
end
