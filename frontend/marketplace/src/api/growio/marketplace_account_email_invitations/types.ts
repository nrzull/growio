import { MarketplaceAccountRole } from "~/api/growio/marketplace_account_roles/types";

export type MarketplaceAccountEmailInvitation = {
  id: number;
  email: string;
  role?: MarketplaceAccountRole;
};