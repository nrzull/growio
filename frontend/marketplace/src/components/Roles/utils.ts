import { MarketplaceAccountRole } from "~/api/growio/marketplace_account_roles/types";
import { PartialMarketplaceAccountRole } from "~/components/Roles/types";

export const buildMarketplaceAccountRole =
  (): PartialMarketplaceAccountRole => ({
    name: "",
    description: "",
    permissions: [],
  });

export const isMarketplaceAccountRole = (v): v is MarketplaceAccountRole =>
  "id" in v;
