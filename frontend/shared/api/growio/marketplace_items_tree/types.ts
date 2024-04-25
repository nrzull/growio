import { MarketplaceItemCategory } from "@growio/shared/api/growio/marketplace_item_categories/types";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";
import { MarketplaceItemAsset } from "../marketplace_item_assets/types";

export type MarketplaceTreeCategory = MarketplaceItemCategory & {
  children: MarketplaceItemsTree;
};

export type MarketplaceTreeItem = MarketplaceItem & {
  assets?: MarketplaceItemAsset[];
};

export type MarketplaceTreeEntity =
  | MarketplaceTreeCategory
  | MarketplaceTreeItem;

export type MarketplaceItemsTree = Array<MarketplaceTreeEntity>;
