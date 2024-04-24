import { MarketplaceItemsTree } from "../marketplace_items_tree/types";
import { MarketplaceOrder } from "../marketplace_orders/types";
import { Marketplace } from "../marketplaces/types";

export type MarketplacePayload = {
  order: MarketplaceOrder;
  marketplace: Marketplace;
  items: MarketplaceItemsTree;
};
