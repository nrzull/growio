import { MarketplaceAccount } from "~/api/growio/marketplace_accounts/types";
import { growio } from "~/api/growio";
import { IdParam } from "~/api/types";

export const apiMarketplaceAccountsGetSelf = () =>
  growio
    .get<MarketplaceAccount[]>("/api/marketplace_accounts/self")
    .then((r) => r.data);

export const apiMarketplaceAccountsGetSelfActive = () =>
  growio
    .get<MarketplaceAccount>("/api/marketplace_accounts/self/active")
    .then((r) => r.data);

export const apiMarketplaceAccountsGetAll = (
  params: { blocked_at?: boolean } = { blocked_at: false }
) =>
  growio
    .get<MarketplaceAccount[]>("/api/marketplace_accounts", { params })
    .then((r) => r.data);

export const apiMarketplaceAccountsUpdate = (params: {
  id: IdParam;
  role_id: IdParam;
}) =>
  growio
    .patch<MarketplaceAccount>(`/api/marketplace_accounts/${params.id}`, params)
    .then((r) => r.data);

export const apiMarketplaceAccountsBlock = (params: MarketplaceAccount) =>
  growio
    .delete<MarketplaceAccount>(`/api/marketplace_accounts/${params.id}`)
    .then((r) => r.data);
