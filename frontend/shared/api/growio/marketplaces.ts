import { growio } from "@growio/shared/api/growio";
import { Marketplace } from "@growio/shared/api/growio/marketplaces/types";
import { MarketplaceOrder } from "@growio/shared/api/growio/marketplace_orders/types";
import { MarketplaceTelegramBot } from "./marketplace_telegram_bots/types";

export const apiMarketplacesCreate = (params: { name: string }) =>
  growio.post<Marketplace>("/api/marketplaces", params).then((r) => r.data);

export const apiMarketplaceUpdate = (params: Marketplace) =>
  growio.patch<Marketplace>("/api/marketplace", params).then((r) => r.data);

export const apiMarketplaceGetAllOrders = () =>
  growio.get<MarketplaceOrder[]>("/api/marketplace/orders").then((r) => r.data);

export const apiMarketplaceGetAllIntegrations = () =>
  growio
    .get<MarketplaceTelegramBot[]>(`/api/marketplace/integrations`)
    .then((r) => r.data);
