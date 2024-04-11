import { MarketplaceItemAsset } from "~/api/growio/marketplace_item_assets/types";
import { isPlainObject } from "remeda";

export const isMarketplaceItemAsset = (v: unknown): v is MarketplaceItemAsset =>
  isPlainObject(v) && ["id", "src", "mimetype"].every((key) => key in v);
