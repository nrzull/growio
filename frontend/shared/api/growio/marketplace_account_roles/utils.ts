import {
  MarketplaceAccountRole,
  PartialMarketplaceAccountRole,
} from "@growio/shared/api/growio/marketplace_account_roles/types";
import { isPlainObject } from "remeda";

export const buildPartialMarketplaceAccountRole =
  (): PartialMarketplaceAccountRole => ({
    name: "",
    description: "",
    permissions: [],
  });

export const isMarketplaceAccountRole = (
  v: unknown
): v is MarketplaceAccountRole => isPlainObject(v) && !!v.id;
