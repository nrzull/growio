import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "@growio/shared/api/growio/marketplace_items/types";
import { isPlainObject, mergeDeep } from "remeda";

export const isMarketplaceItem = (v: unknown): v is MarketplaceItem =>
  isPlainObject(v) && ["id", "quantity"].every((vv) => vv in v);

export const buildPartialMarketplaceItem = (
  params: Partial<PartialMarketplaceItem> = {}
): PartialMarketplaceItem =>
  mergeDeep(
    {
      name: undefined,
      category_id: undefined,
      description: undefined,
      infinity: undefined,
      quantity: undefined,
      price: undefined,
    } as PartialMarketplaceItem,
    params as PartialMarketplaceItem
  );
