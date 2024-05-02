export type MarketplaceTelegramBotCustomerMessage = {
  id: number;
  text: string;
  inserted_at: string;
  customer_id: number;
  read?: boolean;
  marketplace_account_id?: number;
};
