defmodule GrowioWeb.Router do
  use GrowioWeb, :router
  alias GrowioWeb.Controllers.AuthController
  alias GrowioWeb.Controllers.AccountController
  alias GrowioWeb.Controllers.PermissionController
  alias GrowioWeb.Controllers.MarketplaceAccountController
  alias GrowioWeb.Controllers.MarketplaceController
  alias GrowioWeb.Controllers.MarketplaceAccountEmailInvitationController
  alias GrowioWeb.Controllers.MarketplaceAccountRoleController
  alias GrowioWeb.Controllers.MarketplaceItemCategoryController
  alias GrowioWeb.Controllers.MarketplaceItemAssetController
  alias GrowioWeb.Controllers.MarketplaceItemController
  alias GrowioWeb.Plugs.AuthPlug
  alias GrowioWeb.Plugs.MarketplaceAccountPlug

  pipeline :guest do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: GrowioWeb.ApiSpec)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  pipeline :account do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: GrowioWeb.ApiSpec)
    plug(AuthPlug)
  end

  pipeline :marketplace_account do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: GrowioWeb.ApiSpec)
    plug(AuthPlug)
    plug(MarketplaceAccountPlug)
  end

  scope "/api/auth" do
    pipe_through([:guest])
    post("/email", AuthController, :email)
    post("/email/otp", AuthController, :email_otp)

    pipe_through([:account])
    get("/healthcheck", AuthController, :healthcheck)
    get("/signout", AuthController, :signout)
  end

  scope "/api/accounts" do
    pipe_through([:account])
    get("/self", AccountController, :self)
  end

  scope "/api/marketplace_accounts" do
    pipe_through([:account])
    get("/self", MarketplaceAccountController, :self)
    get("/self/active", MarketplaceAccountController, :self_active)

    pipe_through([:marketplace_account])
    get("/", MarketplaceAccountController, :index)
  end

  scope "/api/marketplaces" do
    pipe_through([:account])
    post("/", MarketplaceController, :create)
  end

  scope "/api/marketplace_account_email_invitations" do
    pipe_through([:guest])
    get("/:email/:password", MarketplaceAccountEmailInvitationController, :guest_show)
    post("/:email/:password/accept", MarketplaceAccountEmailInvitationController, :guest_accept)

    pipe_through([:marketplace_account])
    resources("/", MarketplaceAccountEmailInvitationController, only: [:index, :create])
  end

  scope "/api/marketplace_account_roles" do
    pipe_through([:marketplace_account])
    resources("/", MarketplaceAccountRoleController, only: [:index, :create, :update, :delete])
  end

  scope "/api/marketplace_item_categories" do
    pipe_through([:marketplace_account])
    resources("/", MarketplaceItemCategoryController, only: [:index, :create, :update, :delete])

    resources("/:category_id/marketplace_items", MarketplaceItemController,
      only: [:index, :create, :update, :delete]
    )

    resources(
      "/:category_id/marketplace_items/:item_id/marketplace_item_assets",
      MarketplaceItemAssetController,
      only: [:index, :create, :delete]
    )
  end

  scope "/api/permissions" do
    pipe_through([:account])
    resources("/", PermissionController, only: [:index])
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
