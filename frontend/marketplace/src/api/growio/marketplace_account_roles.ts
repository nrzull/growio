import { growio } from "~/api/growio";
import { MarketplaceAccountRole } from "~/api/growio/marketplace_account_roles/types";

export const apiMarketplaceAccountRolesGetAll = () =>
  growio
    .get<MarketplaceAccountRole[]>("/api/marketplace_account_roles")
    .then((r) => r.data);
