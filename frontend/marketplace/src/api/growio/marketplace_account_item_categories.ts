import { growio } from "~/api/growio";
import { MarketplaceAccountItemCategory } from "~/api/growio/marketplace_account_item_categories/types";

export const apiMarketplaceAccountItemCategoriesGetAll = () =>
  growio
    .get<MarketplaceAccountItemCategory[]>(
      "/api/marketplace_account_item_categories"
    )
    .then((r) => r.data);

export const apiMarketplaceAccountItemCategoriesCreate = (params: {
  name: string;
}) =>
  growio
    .post<MarketplaceAccountItemCategory>(
      "/api/marketplace_account_item_categories",
      params
    )
    .then((r) => r.data);
