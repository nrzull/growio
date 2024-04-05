import { MarketplaceAccountRole } from "~/api/growio/marketplace_account_roles/types";

export type PartialMarketplaceAccountRole = Pick<
  MarketplaceAccountRole,
  "name" | "description" | "permissions"
>;
