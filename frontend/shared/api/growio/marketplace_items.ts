import { growio } from "@growio/shared/api/growio";
import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "@growio/shared/api/growio/marketplace_items/types";
import { IdParam } from "@growio/shared/api/types";

export const apiMarketplaceItemsSelfGetAll = (params: {
  deleted_at?: boolean;
}) => {
  const { deleted_at = false } = params;

  return growio
    .get<MarketplaceItem[]>(`/api/marketplace_items`, {
      params: { deleted_at },
    })
    .then((r) => r.data);
};

export const apiMarketplaceItemsGetAll = (params: {
  category_item_id: IdParam;
  deleted_at?: boolean;
}) => {
  const { deleted_at = false } = params;

  return growio
    .get<
      MarketplaceItem[]
    >(`/api/marketplace_item_categories/${params.category_item_id}/marketplace_items`, { params: { deleted_at } })
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

export const apiMarketplaceItemsDelete = (params: MarketplaceItem) =>
  growio
    .delete<MarketplaceItem>(
      `/api/marketplace_item_categories/${params.category_id}/marketplace_items/${params.id}`
    )
    .then((r) => r.data);
