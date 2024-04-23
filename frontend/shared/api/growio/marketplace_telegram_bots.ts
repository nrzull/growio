import { growio } from "@growio/shared/api/growio";
import {
  MarketplaceTelegramBotNew,
  MarketplaceTelegramBot,
} from "@growio/shared/api/growio/marketplace_telegram_bots/types";

export const apiMarketplaceTelegramBotsCreate = (
  params: MarketplaceTelegramBotNew
) =>
  growio.post<MarketplaceTelegramBot>(`/api/marketplace/telegram_bots`, params);

export const apiMarketplaceTelegramBotsDelete = (
  params: MarketplaceTelegramBot
) =>
  growio
    .delete<MarketplaceTelegramBot>(
      `/api/marketplace/telegram_bots/${params.id}`
    )
    .then((r) => r.data);

export const apiMarketplaceTelegramBotGetSelf = () =>
  growio
    .get<MarketplaceTelegramBot>(`/api/marketplace/telegram_bot`)
    .then((r) => r.data);

export const apiMarketplaceTelegramBotUpdateSelf = (
  params: MarketplaceTelegramBot
) =>
  growio
    .patch<MarketplaceTelegramBot>(`/api/marketplace/telegram_bot`, params)
    .then((r) => r.data);
