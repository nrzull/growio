import {
  MarketplaceMarketItem,
  PartialMarketplaceMarketItem,
} from "~/api/growio/marketplace_market_items/types";
import { growio } from "~/api/growio";
import { IdParam } from "~/api/types";

export const apiMarketplaceMarketItemsGetAll = (params: {
  market_id: IdParam;
}) =>
  growio
    .get<MarketplaceMarketItem[]>(
      `/api/marketplace_markets/${params.market_id}/marketplace_market_items`
    )
    .then((r) => r.data);

export const apiMarketplaceMarketItemsCreate = (params: {
  market_id: IdParam;
  item: PartialMarketplaceMarketItem;
}) =>
  growio
    .post<MarketplaceMarketItem>(
      `/api/marketplace_markets/${params.market_id}/marketplace_market_items`,
      params.item
    )
    .then((r) => r.data);

export const apiMarketplaceMarketItemsUpdate = (params: {
  market_id: IdParam;
  item: PartialMarketplaceMarketItem & { id: IdParam };
}) =>
  growio
    .patch<MarketplaceMarketItem>(
      `/api/marketplace_markets/${params.market_id}/marketplace_market_items/${params.item.id}`,
      params.item
    )
    .then((r) => r.data);

export const apiMarketplaceMarketItemsDelete = (params: {
  market_id: IdParam;
  item: MarketplaceMarketItem;
}) =>
  growio
    .delete<MarketplaceMarketItem>(
      `/api/marketplace_markets/${params.market_id}/marketplace_market_items/${params.item.id}`
    )
    .then((r) => r.data);
