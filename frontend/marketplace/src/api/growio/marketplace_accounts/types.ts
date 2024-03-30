import type { Marketplace } from "~/api/growio/marketplaces/types";
import { MarketplaceAccountRole } from "~/api/growio/types";

export type MarketplaceAccount = {
  id: number;
  marketplace: Marketplace;
  role: MarketplaceAccountRole;
};
