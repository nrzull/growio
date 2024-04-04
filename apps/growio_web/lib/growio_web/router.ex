defmodule GrowioWeb.Router do
  use GrowioWeb, :router
  alias GrowioWeb.Controllers.AuthController
  alias GrowioWeb.Controllers.AccountController
  alias GrowioWeb.Controllers.MarketplaceAccountController
  alias GrowioWeb.Controllers.MarketplaceController
  alias GrowioWeb.Plugs.AuthPlug
  alias GrowioWeb.Plugs.MarketplaceAccountPlug

  pipeline :guest do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: GrowioWeb.ApiSpec)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  pipeline :account_api do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: GrowioWeb.ApiSpec)
    plug(AuthPlug)
  end

  pipeline :api do
    plug(MarketplaceAccountPlug)
  end

  scope "/api/auth" do
    pipe_through([:guest])
    post("/email", AuthController, :email)
    post("/email/otp", AuthController, :email_otp)

    pipe_through([:account_api])
    get("/healthcheck", AuthController, :healthcheck)
    get("/signout", AuthController, :signout)
  end

  scope "/api/accounts" do
    pipe_through([:account_api])
    get("/self", AccountController, :self)
  end

  scope "/api/marketplace_accounts" do
    pipe_through([:account_api])
    get("/self", MarketplaceAccountController, :self)
    get("/self/active", MarketplaceAccountController, :self_active)

    pipe_through([:api])
    get("/", MarketplaceAccountController, :index)
  end

  scope "/api/marketplaces" do
    pipe_through([:account_api])
    post("/", MarketplaceController, :create)
  end

  if Application.compile_env(:growio_web, :dev_routes) do
    scope "/dev" do
      pipe_through([:fetch_session, :protect_from_forgery])
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  if Application.compile_env(:growio_web, :swaggerui_routes) do
    scope "/swaggerui" do
      pipe_through([:browser])
      get("/", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi")
    end

    scope "/api/openapi" do
      pipe_through([:guest])
      get("/", OpenApiSpex.Plug.RenderSpec, [])
    end
  end
end
