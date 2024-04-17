import {
  MarketplaceMarket,
  PartialMarketplaceMarket,
} from "~/api/growio/marketplace_markets/types";
import { growio } from "~/api/growio";
import { IdParam } from "~/api/types";

export const apiMarketplaceMarketsGetAll = () =>
  growio
    .get<MarketplaceMarket[]>("/api/marketplace_markets")
    .then((r) => r.data);

export const apiMarketplaceMarketsGetOne = (params: { market_id: IdParam }) =>
  growio
    .get<MarketplaceMarket>(`/api/marketplace_markets/${params.market_id}`)
    .then((r) => r.data);

export const apiMarketplaceMarketsCreate = (params: PartialMarketplaceMarket) =>
  growio
    .post<MarketplaceMarket>("/api/marketplace_markets", params)
    .then((r) => r.data);

export const apiMarketplaceMarketsUpdate = (params: MarketplaceMarket) =>
  growio
    .patch<MarketplaceMarket>(`/api/marketplace_markets/${params.id}`, params)
    .then((r) => r.data);

export const apiMarketplaceMarketsDelete = (params: MarketplaceMarket) =>
  growio
    .delete<MarketplaceMarket>(`/api/marketplace_markets/${params.id}`)
    .then((r) => r.data);
