import {
  MarketplaceItemAsset,
  PartialMarketplaceItemAsset,
} from "~/api/growio/marketplace_item_assets/types";
import { growio } from "~/api/growio";
import { IdParam } from "~/api/types";

export const apiMarketplaceItemAssetsGetAll = (params: {
  category_id: IdParam;
  item_id: IdParam;
}) =>
  growio
    .get<MarketplaceItemAsset[]>(
      `/api/marketplace_item_categories/${params.category_id}/marketplace_items/${params.item_id}/marketplace_item_assets`
    )
    .then((r) => r.data);

export const apiMarketplaceItemAssetsCreate = (params: {
  category_id: IdParam;
  item_id: IdParam;
  asset: PartialMarketplaceItemAsset;
}) =>
  growio
    .post<MarketplaceItemAsset>(
      `/api/marketplace_item_categories/${params.category_id}/marketplace_items/${params.item_id}/marketplace_item_assets`,
      params.asset
    )
    .then((r) => r.data);

export const apiMarketplaceItemAssetsDelete = (params: {
  category_id: IdParam;
  item_id: IdParam;
  asset: MarketplaceItemAsset;
}) =>
  growio
    .delete<MarketplaceItemAsset>(
      `/api/marketplace_item_categories/${params.category_id}/marketplace_items/${params.item_id}/marketplace_item_assets/${params.asset.id}`
    )
    .then((r) => r.data);
