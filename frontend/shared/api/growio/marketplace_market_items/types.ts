import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";
import { MarketplaceMarket } from "@growio/shared/api/growio/marketplace_markets/types";

export type MarketplaceMarketItem = {
  id: number;
  infinity: boolean;
  quantity: number;
  marketplace_item: MarketplaceItem;
  marketplace_item_id: number;
  market: MarketplaceMarket;
};

export type PartialMarketplaceMarketItem = Pick<
  MarketplaceMarketItem,
  "infinity" | "quantity" | "marketplace_item_id"
>;
