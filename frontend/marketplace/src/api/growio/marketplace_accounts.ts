import { MarketplaceAccount } from "~/api/growio/marketplace_accounts/types";
import { growio } from "~/api/growio";

export const apiMarketplaceAccountsGetSelf = () =>
  growio
    .get<MarketplaceAccount[]>("/marketplace_accounts/self")
    .then((r) => r.data);

export const apiMarketplaceAccountsGetSelfActive = () =>
  growio
    .get<MarketplaceAccount>("/marketplace_accounts/self/active")
    .then((r) => r.data);
