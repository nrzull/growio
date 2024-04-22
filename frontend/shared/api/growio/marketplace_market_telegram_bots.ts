import { growio } from "@growio/shared/api/growio";
import {
  MarketplaceMarketTelegramBotNew,
  MarketplaceMarketTelegramBot,
} from "@growio/shared/api/growio/marketplace_market_telegram_bots/types";
import { IdParam } from "@growio/shared/api/types";

export const apiMarketplaceMarketTelegramBotsCreate = (
  params: MarketplaceMarketTelegramBotNew
) =>
  growio.post<MarketplaceMarketTelegramBot>(
    `/api/marketplace_markets/${params.marketplace_market_id}/marketplace_market_telegram_bots`,
    params
  );

export const apiMarketplaceMarketTelegramBotsDelete = (
  params: MarketplaceMarketTelegramBot
) =>
  growio
    .delete<MarketplaceMarketTelegramBot>(
      `/api/marketplace_markets/${params.marketplace_market_id}/marketplace_market_telegram_bots/${params.id}`
    )
    .then((r) => r.data);

export const apiMarketplaceMarketTelegramBotGetSelf = (params: {
  market_id: IdParam;
}) =>
  growio
    .get<MarketplaceMarketTelegramBot>(
      `/api/marketplace_markets/${params.market_id}/marketplace_market_telegram_bot`
    )
    .then((r) => r.data);

export const apiMarketplaceMarketTelegramBotUpdateSelf = (
  params: MarketplaceMarketTelegramBot
) =>
  growio
    .patch<MarketplaceMarketTelegramBot>(
      `/api/marketplace_markets/${params.marketplace_market_id}/marketplace_market_telegram_bot`,
      params
    )
    .then((r) => r.data);
