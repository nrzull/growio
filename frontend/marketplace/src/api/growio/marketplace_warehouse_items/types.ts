import { MarketplaceItem } from "~/api/growio/marketplace_items/types";
import { MarketplaceWarehouse } from "~/api/growio/marketplace_warehouses/types";

export type MarketplaceWarehouseItem = {
  id: number;
  infinity: boolean;
  quantity: number;
  marketplace_item: MarketplaceItem;
  marketplace_item_id?: number;
  warehouse: MarketplaceWarehouse;
};

export type PartialMarketplaceWarehouseItem = {
  infinity: boolean;
  quantity: number;
  marketplace_item_id: number;
};
