defmodule GrowioWeb.Views.JSON do
  def ok(assigns), do: Map.get(assigns, :payload)

  def error(assigns), do: %{errors: Map.get(assigns, :errors)}

  def render(template, _assigns) do
    %{
      errors: %{
        detail: Phoenix.Controller.status_message_from_template(template)
      }
    }
  end
end
