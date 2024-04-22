import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "@growio/shared/api/growio/marketplace_items/types";
import { isPlainObject, mergeDeep } from "remeda";

export const isMarketplaceItem = (v: unknown): v is MarketplaceItem =>
  isPlainObject(v) && !!v.id;

export const buildPartialMarketplaceItem = (
  params: Partial<PartialMarketplaceItem> = {}
): PartialMarketplaceItem =>
  mergeDeep({ name: "", category_id: 0 }, params as PartialMarketplaceItem);
