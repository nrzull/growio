defmodule Growio.WarehousesFixture do
  alias Growio.Utils
  alias Growio.Marketplaces.Marketplace
  alias Growio.Warehouses

  def warehouse!(%Marketplace{} = marketplace) do
    {:ok, result} =
      Warehouses.create_warehouse(marketplace, %{
        name: "warehouse #{Utils.gen_integer(1..6)}"
      })

    result
  end
end
