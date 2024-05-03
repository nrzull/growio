import { growio } from "../growio";
import { IdParam } from "../types";
import { MarketplaceTelegramBotCustomerMessage } from "./marketplace_telegram_bot_customer_messages/types";

export const apiMarketplaceTelegramBotCustomerMessagesCreate = (params: {
  customer_id: IdParam;
  text: string;
}) =>
  growio
    .post<MarketplaceTelegramBotCustomerMessage>(
      `/api/marketplace/telegram_bot/customers/${params.customer_id}/messages`,
      params
    )
    .then((r) => r.data);

export const apiMarketplaceTelegramBotCustomerMessagesGetAll = (params: {
  customer_id: IdParam;
}) =>
  growio
    .get<
      MarketplaceTelegramBotCustomerMessage[]
    >(`/api/marketplace/telegram_bot/customers/${params.customer_id}/messages`)
    .then((r) => r.data);
