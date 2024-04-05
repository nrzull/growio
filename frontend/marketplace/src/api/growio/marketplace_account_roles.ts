import { growio } from "~/api/growio";
import { MarketplaceAccountRole } from "~/api/growio/types";

export const apiMarketplaceAccountRolesGetAll = () =>
  growio
    .get<MarketplaceAccountRole[]>("/api/marketplace_account_roles")
    .then((r) => r.data);
