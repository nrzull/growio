import { MarketplaceTreeItemCategory } from "~/api/growio/marketplace_items_tree/types";
import { isPlainObject } from "remeda";

export const isMarketplaceTreeItemCategory = (
  v: unknown
): v is MarketplaceTreeItemCategory =>
  isPlainObject(v) && ["id", "children"].every((vv) => vv in v);
