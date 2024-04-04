import type { Account } from "~/api/growio/accounts/types";
import type { Marketplace } from "~/api/growio/marketplaces/types";
import type { MarketplaceAccountRole } from "~/api/growio/types";

export type MarketplaceAccount = {
  id: number;
  marketplace: Marketplace;
  role: MarketplaceAccountRole;
  account: Account;
};
