defmodule Growio.Permissions do
  alias Growio.Repo
  alias Growio.Permissions.Permission

  defmodule Macro do
    defmacro permissions(prefix, entity, actions \\ ["create", "read", "update", "delete"]) do
      for action <- actions do
        quote do
          def unquote(:"#{prefix}__#{entity}__#{action}")() do
            unquote("#{prefix}__#{entity}__#{action}")
          end
        end
      end
    end
  end

  defmodule Definitions do
    import Growio.Permissions.Macro

    permissions("bots", "telegram_bot")
    permissions("marketplaces", "marketplace_item")
    permissions("marketplaces", "marketplace_item_category")
    permissions("marketplaces", "marketplace_item_asset")
  end

  def all() do
    for {name, _} <- Growio.Permissions.Definitions.__info__(:functions) do
      Task.async(fn ->
        Repo.get_by(
          Permission,
          name: apply(Growio.Permissions.Definitions, name, [])
        )
      end)
    end
    |> Task.await_many()
  end
end
