import {
  MarketplaceTelegramBot,
  MarketplaceTelegramBotNew,
} from "@growio/shared/api/growio/marketplace_telegram_bots/types";
import { isPlainObject } from "remeda";

export const isMarketplaceTelegramBot = (
  v: unknown
): v is MarketplaceTelegramBot =>
  isPlainObject(v) && ["id", "token", "marketplace_id"].every((vv) => vv in v);

export const buildMarketplaceTelegramBotNew =
  (): MarketplaceTelegramBotNew => ({
    token: undefined,
    marketplace_id: undefined,
    description: undefined,
    short_description: undefined,
    name: undefined,
    welcome_message: undefined,
  });
