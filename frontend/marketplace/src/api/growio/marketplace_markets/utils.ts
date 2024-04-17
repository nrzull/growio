import { isPlainObject } from "remeda";
import {
  MarketplaceMarket,
  PartialMarketplaceMarket,
} from "~/api/growio/marketplace_markets/types";

export const isMarketplaceMarket = (v: unknown): v is MarketplaceMarket =>
  isPlainObject(v) && ["id", "name"].every((vv) => vv in v);

export const buildPartialMarketplaceMarket = (): PartialMarketplaceMarket => ({
  name: undefined,
  address: undefined,
});
