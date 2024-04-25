import {
  MarketplaceTreeCategory,
  MarketplaceTreeItem,
} from "@growio/shared/api/growio/marketplace_items_tree/types";
import { isPlainObject } from "remeda";

export const isMarketplaceTreeItemCategory = (
  v: unknown
): v is MarketplaceTreeCategory =>
  isPlainObject(v) && ["id", "children"].every((vv) => vv in v);

export const isMarketplaceTreeItem = (v: unknown): v is MarketplaceTreeItem =>
  isPlainObject(v) && ["id", "assets"].every((vv) => vv in v);
