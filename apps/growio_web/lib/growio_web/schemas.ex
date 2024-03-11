defmodule GrowioWeb.Schemas do
  alias OpenApiSpex.Schema
  import OpenApiSpex

  defmodule Account do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer, minimum: 1},
        email: %Schema{type: :string}
      }
    })
  end

  defmodule AuthRequest do
    schema(%{
      type: :object,
      properties: %{
        email: %Schema{type: :string}
      }
    })
  end
end
