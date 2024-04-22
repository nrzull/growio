import { growio } from "@growio/shared/api/growio";
import { Marketplace } from "@growio/shared/api/growio/marketplaces/types";
import { MarketplaceMarketOrder } from "@growio/shared/api/growio/marketplace_market_orders/types";

export const apiMarketplacesCreate = (params: { name: string }) =>
  growio.post<Marketplace>("/api/marketplaces", params).then((r) => r.data);

export const apiMarketplaceUpdate = (params: Marketplace) =>
  growio.patch<Marketplace>("/api/marketplace", params).then((r) => r.data);

export const apiMarketplaceGetAllOrders = () =>
  growio
    .get<MarketplaceMarketOrder[]>("/api/marketplace/orders")
    .then((r) => r.data);
