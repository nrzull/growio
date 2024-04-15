import { isPlainObject } from "remeda";
import {
  MarketplaceWarehouse,
  PartialMarketplaceWarehouse,
} from "~/api/growio/marketplace_warehouses/types";

export const isMarketplaceWarehouse = (v: unknown): v is MarketplaceWarehouse =>
  isPlainObject(v) && ["id", "name"].every((vv) => vv in v);

export const buildPartialMarketplaceWarehouse =
  (): PartialMarketplaceWarehouse => ({ name: undefined, address: undefined });
