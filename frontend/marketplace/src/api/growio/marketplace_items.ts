import { growio } from "~/api/growio";
import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "~/api/growio/marketplace_items/types";
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

export const apiMarketplaceItemsCreate = (params: PartialMarketplaceItem) =>
  growio
    .post<MarketplaceItem>(
      `/api/marketplace_item_categories/${params.category_id}/marketplace_items`,
      params
    )
    .then((r) => r.data);

export const apiMarketplaceItemsUpdate = (params: {
  category_id: IdParam;
  item: MarketplaceItem;
}) =>
  growio
    .patch<MarketplaceItem>(
      `/api/marketplace_item_categories/${params.category_id}/marketplace_items/${params.item.id}`,
      params.item
    )
    .then((r) => r.data);
