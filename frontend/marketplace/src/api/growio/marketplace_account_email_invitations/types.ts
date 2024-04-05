import { MarketplaceAccountRole } from "~/api/growio/types";

export type MarketplaceAccountEmailInvitation = {
  id: number;
  email: string;
  role?: MarketplaceAccountRole;
};
