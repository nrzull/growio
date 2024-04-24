export type MarketplaceTelegramBot = {
  id: number;
  token: string;
  name?: string;
  tag?: string;
  description?: string;
  short_description?: string;
  welcome_message?: string;
  marketplace_id: number;
  is_telegram?: boolean;
};

export type MarketplaceTelegramBotNew = Pick<
  MarketplaceTelegramBot,
  | "marketplace_id"
  | "token"
  | "name"
  | "description"
  | "short_description"
  | "welcome_message"
>;
