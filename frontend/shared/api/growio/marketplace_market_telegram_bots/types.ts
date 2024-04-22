export type MarketplaceMarketTelegramBot = {
  id: number;
  token: string;
  name?: string;
  description?: string;
  short_description?: string;
  welcome_message?: string;
  marketplace_market_id: number;
};

export type MarketplaceMarketTelegramBotNew = Pick<
  MarketplaceMarketTelegramBot,
  | "marketplace_market_id"
  | "token"
  | "name"
  | "description"
  | "short_description"
  | "welcome_message"
>;
