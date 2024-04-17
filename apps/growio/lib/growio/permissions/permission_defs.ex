defmodule Growio.Permissions.Macro do
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

defmodule Growio.Permissions.PermissionDefs do
  import Growio.Permissions.Macro

  permissions("bots", "telegram_bot")
  permissions("marketplaces", "marketplace", ["update"])
  permissions("marketplaces", "marketplace_account")
  permissions("marketplaces", "marketplace_account_role")
  permissions("marketplaces", "marketplace_item")
  permissions("marketplaces", "marketplace_item_category")
  permissions("marketplaces", "marketplace_item_asset")
  permissions("marketplaces", "marketplace_account_email_invitation")
  permissions("marketplaces", "market")
  permissions("marketplaces", "market_item")
end
