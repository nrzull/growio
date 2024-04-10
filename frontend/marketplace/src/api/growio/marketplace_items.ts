import { growio } from "~/api/growio";
import { MarketplaceItem } from "~/api/growio/marketplace_items/types";
import { IdParam } from "~/api/types";

export const apiMarketplaceItemsGetAll = (params: {
  category_item_id: IdParam;
  deleted_at?: boolean;
}) => {
  const { deleted_at = false } = params;

  return growio
    .get<MarketplaceItem[]>(
      `/api/marketplace_item_categories/${params.category_item_id}/marketplace_items`,
      { params: { deleted_at } }
    )
    .then((r) => r.data);
};

export const apiMarketplaceItemsCreate = (params: {
  category_item_id: IdParam;
  item: { name: string };
}) =>
  growio
    .post<MarketplaceItem>(
      `/api/marketplace_item_categories/${params.category_item_id}/marketplace_items`,
      params.item
    )
    .then((r) => r.data);
