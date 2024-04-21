import { growio } from "~/api/growio";
import { Marketplace } from "~/api/growio/marketplaces/types";
import { MarketplaceMarketOrder } from "~/api/growio/marketplace_market_orders/types";

export const apiMarketplacesCreate = (params: { name: string }) =>
  growio.post<Marketplace>("/api/marketplaces", params).then((r) => r.data);

export const apiMarketplaceUpdate = (params: Marketplace) =>
  growio.patch<Marketplace>("/api/marketplace", params).then((r) => r.data);

export const apiMarketplaceGetAllOrders = () =>
  growio
    .get<MarketplaceMarketOrder[]>("/api/marketplace/orders")
    .then((r) => r.data);
