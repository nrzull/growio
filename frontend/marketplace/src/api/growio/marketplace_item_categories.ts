import { growio } from "~/api/growio";
import { MarketplaceItemCategory } from "~/api/growio/marketplace_item_categories/types";

export const apiMarketplaceItemCategoriesGetAll = () =>
  growio
    .get<MarketplaceItemCategory[]>("/api/marketplace_item_categories")
    .then((r) => r.data);

export const apiMarketplaceItemCategoriesCreate = (params: { name: string }) =>
  growio
    .post<MarketplaceItemCategory>("/api/marketplace_item_categories", params)
    .then((r) => r.data);
