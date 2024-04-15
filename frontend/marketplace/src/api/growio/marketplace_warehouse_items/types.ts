import { MarketplaceItem } from "~/api/growio/marketplace_items/types";
import { MarketplaceWarehouse } from "~/api/growio/marketplace_warehouses/types";

export type MarketplaceWarehouseItem = {
  id: number;
  infinity: boolean;
  quantity: number;
  marketplace_item: MarketplaceItem;
  warehouse: MarketplaceWarehouse;
};
