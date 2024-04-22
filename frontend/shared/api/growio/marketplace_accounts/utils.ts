import { MarketplaceAccount } from "@growio/shared/api/growio/marketplace_accounts/types";
import { isPlainObject } from "remeda";

export const isMarketplaceAccount = (v: unknown): v is MarketplaceAccount =>
  isPlainObject(v) && ["id", "role", "account"].every((vv) => vv in v);
