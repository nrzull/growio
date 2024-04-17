import { growio } from "~/api/growio";
import { MarketplaceItemsTree } from "~/api/growio/marketplace_items_tree/types";

export const apiMarketplaceItemsTree = (
  params: { deleted_at?: boolean } = { deleted_at: false }
) =>
  growio
    .get<MarketplaceItemsTree>("/api/marketplace_items_tree", { params })
    .then((r) => r.data);
