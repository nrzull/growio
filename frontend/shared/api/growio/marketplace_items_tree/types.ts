import { MarketplaceItemCategory } from "@growio/shared/api/growio/marketplace_item_categories/types";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";

export type MarketplaceTreeItemCategory = MarketplaceItemCategory & {
  children: MarketplaceItemCategory[];
};

export type MarketplaceItemsTree = Array<
  MarketplaceTreeItemCategory | MarketplaceItem
>;
