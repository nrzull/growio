defmodule GrowioWeb.Router do
  use GrowioWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GrowioWeb do
    pipe_through :api
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:growio_web, :dev_routes) do

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
