import { growio } from "../growio";
import { MarketplaceTelegramBotCustomer } from "./marketplace_telegram_bot_customers/types";

export const apiMarketplaceTelegramBotCustomersGetAll = (
  params: {
    filters?: {
      conversation?: boolean;
    };
  } = {}
) => {
  const { filters = {} } = params;

  return growio
    .get<
      MarketplaceTelegramBotCustomer[]
    >("/api/marketplace/telegram_bot/customers", { params: { filters } })
    .then((r) => r.data);
};
