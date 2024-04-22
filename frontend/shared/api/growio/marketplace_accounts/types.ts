import type { Account } from "@growio/shared/api/growio/accounts/types";
import type { Marketplace } from "@growio/shared/api/growio/marketplaces/types";
import type { MarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/types";

export type MarketplaceAccount = {
  id: number;
  marketplace: Marketplace;
  role: MarketplaceAccountRole;
  account: Account;
};
