export type MarketplaceOrder = {
  id: string;
  status: string;
  payload: Record<any, any>;
  marketplace_id: number;
  telegram_bot_customer_id?: number;
};
