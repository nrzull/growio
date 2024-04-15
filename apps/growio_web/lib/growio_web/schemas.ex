defmodule GrowioWeb.Schemas do
  alias OpenApiSpex.Schema
  import OpenApiSpex

  defmodule Account do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        email: %Schema{type: :string}
      }
    })
  end

  defmodule Permissions do
    schema(%{
      type: :array,
      items: %Schema{type: :string}
    })
  end

  defmodule Marketplace do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        name: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceAccountRole do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        name: %Schema{type: :string},
        description: %Schema{type: :string, nullable: true},
        priority: %Schema{type: :integer}
      }
    })
  end

  defmodule MarketplaceAccountRoleCreate do
    schema(%{
      type: :object,
      properties: %{
        name: %Schema{type: :string},
        description: %Schema{type: :string, nullable: true},
        permissions: %Schema{type: :array, items: %Schema{type: :string}}
      }
    })
  end

  defmodule MarketplaceAccountRoleUpdate do
    schema(%{
      type: :object,
      properties: %{
        name: %Schema{type: :string},
        description: %Schema{type: :string, nullable: true},
        permissions: %Schema{type: :array, items: %Schema{type: :string}}
      }
    })
  end

  defmodule MarketplaceAccountRoleNullable do
    schema(%{
      type: :object,
      nullable: true,
      properties: %{
        id: %Schema{type: :integer},
        name: %Schema{type: :string},
        description: %Schema{type: :string, nullable: true},
        priority: %Schema{type: :integer}
      }
    })
  end

  defmodule MarketplaceAccountRoles do
    schema(%{
      type: :array,
      items: MarketplaceAccountRole
    })
  end

  defmodule MarketplaceItemCategory do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        name: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceItemCategoryCreate do
    schema(%{
      type: :object,
      properties: %{
        name: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceItemCategories do
    schema(%{
      type: :array,
      items: MarketplaceItemCategory
    })
  end

  defmodule MarketplaceItem do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        name: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceItemCreate do
    schema(%{
      type: :object,
      properties: %{
        name: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceItems do
    schema(%{
      type: :array,
      items: MarketplaceItem
    })
  end

  defmodule MarketplaceItemAsset do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        src: %Schema{type: :string},
        mimetype: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceItemAssets do
    schema(%{
      type: :array,
      items: MarketplaceItemAsset
    })
  end

  defmodule MarketplaceItemAssetCreate do
    schema(%{
      type: :object,
      properties: %{
        src: %Schema{type: :string},
        mimetype: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceAccount do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        role: MarketplaceAccountRoleNullable,
        marketplace: Marketplace,
        account: Account
      }
    })
  end

  defmodule MarketplaceAccounts do
    schema(%{
      type: :array,
      items: MarketplaceAccount
    })
  end

  defmodule MakretplaceAccountUpdate do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        role_id: %Schema{type: :integer}
      }
    })
  end

  defmodule AuthEmailRequest do
    schema(%{
      type: :object,
      properties: %{
        email: %Schema{type: :string}
      }
    })
  end

  defmodule AuthEmailResponse do
    schema(%{
      type: :object,
      properties: %{
        email: %Schema{type: :string},
        password: %Schema{type: :string, nullable: true}
      }
    })
  end

  defmodule AuthEmailOTPRequest do
    schema(%{
      type: :object,
      properties: %{
        email: %Schema{type: :string},
        password: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceCreate do
    schema(%{
      type: :object,
      properties: %{
        name: %Schema{type: :string}
      }
    })
  end

  defmodule MarketplaceAccountEmailInvitation do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        email: %Schema{type: :string},
        role: MarketplaceAccountRoleNullable
      }
    })
  end

  defmodule MarketplaceAccountEmailInvitations do
    schema(%{
      type: :array,
      items: MarketplaceAccountEmailInvitation
    })
  end

  defmodule MarketplaceAccountEmailInvitationCreateRequest do
    schema(%{
      type: :object,
      properties: %{
        email: %Schema{type: :string},
        marketplace_account_role_id: %Schema{type: :integer}
      }
    })
  end

  defmodule MarketplaceWarehouse do
    schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer},
        name: %Schema{type: :string},
        address: %Schema{type: :string, nullable: true}
      }
    })
  end

  defmodule MarketplaceWarehouses do
    schema(%{
      type: :array,
      items: MarketplaceWarehouse
    })
  end

  defmodule MarketplaceWarehouseCreate do
    schema(%{
      type: :object,
      properties: %{
        name: %Schema{type: :string},
        address: %Schema{type: :string, nullable: true}
      }
    })
  end
end
