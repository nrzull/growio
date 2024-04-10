import {
  MarketplaceItemCategory,
  PartialMarketplaceItemCategory,
} from "~/api/growio/marketplace_item_categories/types";
import { isPlainObject } from "remeda";

export const isMarketplaceItemCategory = (
  v: unknown
): v is MarketplaceItemCategory => isPlainObject(v) && !!v.id;

export const buildPartialMarketplaceItemCategory =
  (): PartialMarketplaceItemCategory => ({ name: "" });
