import { MarketplaceAccount } from "~/api/growio/marketplace_accounts/types";
import { growio } from "~/api/growio";

export const apiMarketplaceAccountsGetSelf = () =>
  growio
    .get<MarketplaceAccount[]>("/api/marketplace_accounts/self")
    .then((r) => r.data);

export const apiMarketplaceAccountsGetSelfActive = () =>
  growio
    .get<MarketplaceAccount>("/api/marketplace_accounts/self/active")
    .then((r) => r.data);

export const apiMarketplaceAccountsGetAll = () =>
  growio
    .get<MarketplaceAccount[]>("/api/marketplace_accounts")
    .then((r) => r.data);
