import {
  MarketplaceMarketItem,
  PartialMarketplaceMarketItem,
} from "~/api/growio/marketplace_market_items/types";
import { isPlainObject } from "remeda";

export const isMarketplaceMarketItem = (
  v: unknown
): v is MarketplaceMarketItem =>
  isPlainObject(v) && ["id", "infinity", "quantity"].every((vv) => vv in v);

export const buildPartialMarketplaceMarketItem =
  (): PartialMarketplaceMarketItem => ({
    infinity: false,
    quantity: 1,
    marketplace_item_id: undefined,
  });
