import {
  MarketplaceWarehouseItem,
  PartialMarketplaceWarehouseItem,
} from "~/api/growio/marketplace_warehouse_items/types";
import { isPlainObject } from "remeda";

export const isMarketplaceWarehouseItem = (
  v: unknown
): v is MarketplaceWarehouseItem =>
  isPlainObject(v) && ["id", "infinity", "quantity"].every((vv) => vv in v);

export const buildPartialMarketplaceWarehouseItem =
  (): PartialMarketplaceWarehouseItem => ({
    infinity: false,
    quantity: 1,
    marketplace_item_id: undefined,
  });
