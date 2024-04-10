import { growio } from "~/api/growio";
import { MarketplaceItemCategory } from "~/api/growio/marketplace_item_categories/types";
import { IdParam } from "~/api/types";

export const apiMarketplaceItemCategoriesGetAll = (
  params: { deleted_at?: boolean } = { deleted_at: false }
) =>
  growio
    .get<MarketplaceItemCategory[]>("/api/marketplace_item_categories", {
      params,
    })
    .then((r) => r.data);

export const apiMarketplaceItemCategoriesCreate = (params: { name: string }) =>
  growio
    .post<MarketplaceItemCategory>("/api/marketplace_item_categories", params)
    .then((r) => r.data);

export const apiMarketplaceItemCategoriesDelete = (params: {
  item_category_id: IdParam;
}) =>
  growio
    .delete<MarketplaceItemCategory>(
      `/api/marketplace_item_categories/${params.item_category_id}`
    )
    .then((r) => r.data);
