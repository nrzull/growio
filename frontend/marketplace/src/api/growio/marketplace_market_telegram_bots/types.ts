export type MarketplaceMarketTelegramBot = {
  id: number;
  token: string;
  marketplace_market_id: number;
};

export type MarketplaceMarketTelegramBotNew = Pick<
  MarketplaceMarketTelegramBot,
  "marketplace_market_id" | "token"
>;
