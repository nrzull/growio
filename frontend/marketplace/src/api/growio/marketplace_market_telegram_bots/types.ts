export type MarketplaceMarketTelegramBot = {
  id: number;
  name: string;
  description?: string;
  token: string;
  marketplace_market_id: number;
};

export type MarketplaceMarketTelegramBotNew = Pick<
  MarketplaceMarketTelegramBot,
  "name" | "description" | "marketplace_market_id" | "token"
>;
