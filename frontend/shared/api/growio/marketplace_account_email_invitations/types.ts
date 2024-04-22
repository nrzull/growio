import { Marketplace } from "@growio/shared/api/growio/marketplaces/types";
import { MarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/types";

export type MarketplaceAccountEmailInvitation = {
  id: number;
  email: string;
  role?: MarketplaceAccountRole;
  marketplace?: Marketplace;
};
