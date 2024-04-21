export type MarketplaceMarketOrder = {
  id: string;
  status: string;
  payload: Record<any, any>;
  market_id: number;
  telegram_bot_customer_id?: number;
};
