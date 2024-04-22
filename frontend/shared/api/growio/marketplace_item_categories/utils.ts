import {
  MarketplaceItemCategory,
  PartialMarketplaceItemCategory,
} from "@growio/shared/api/growio/marketplace_item_categories/types";
import { isPlainObject, mergeDeep } from "remeda";

export const isMarketplaceItemCategory = (
  v: unknown
): v is MarketplaceItemCategory =>
  isPlainObject(v) && ["id", "parent_id"].every((vv) => vv in v);

export const buildPartialMarketplaceItemCategory = (
  params: Partial<PartialMarketplaceItemCategory> = {}
): PartialMarketplaceItemCategory =>
  mergeDeep(
    { name: "", parent_id: undefined },
    params as PartialMarketplaceItemCategory
  );
