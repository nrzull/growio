import { growio } from "../growio";
import { IdParam } from "../types";
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

export const apiMarketplaceTelegramBotCustomersGetOne = (params: {
  customer_id: IdParam;
  filters?: {
    conversation?: boolean;
  };
}) => {
  const { filters = {}, customer_id } = params;

  return growio
    .get<MarketplaceTelegramBotCustomer>(
      `/api/marketplace/telegram_bot/customers/${customer_id}`,
      {
        params: { filters },
      }
    )
    .then((r) => r.data);
};
