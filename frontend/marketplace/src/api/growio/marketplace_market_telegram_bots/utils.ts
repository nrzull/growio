import {
  MarketplaceMarketTelegramBot,
  MarketplaceMarketTelegramBotNew,
} from "~/api/growio/marketplace_market_telegram_bots/types";
import { isPlainObject } from "remeda";

export const isMarketplaceMarketTelegramBot = (
  v: unknown
): v is MarketplaceMarketTelegramBot =>
  isPlainObject(v) &&
  ["id", "name", "token", "marketplace_market_id"].every((vv) => vv in v);

export const buildMarketplaceMarketTelegramBotNew =
  (): MarketplaceMarketTelegramBotNew => ({
    name: undefined,
    token: undefined,
    marketplace_market_id: undefined,
  });
