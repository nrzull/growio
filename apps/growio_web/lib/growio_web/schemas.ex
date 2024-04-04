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

  defmodule MarketplaceAccountEmailInvitationCreateRequest do
    schema(%{
      type: :object,
      properties: %{
        email: %Schema{type: :string},
        marketplace_account_role_id: %Schema{type: :integer}
      }
    })
  end
end
