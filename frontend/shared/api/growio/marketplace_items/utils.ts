import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "@growio/shared/api/growio/marketplace_items/types";
import { isPlainObject, mergeDeep } from "remeda";

export const isMarketplaceItem = (v: unknown): v is MarketplaceItem =>
  isPlainObject(v) && ["id"].every((vv) => vv in v && v[vv]);

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
    } as PartialMarketplaceItem,
    params as PartialMarketplaceItem
  );
