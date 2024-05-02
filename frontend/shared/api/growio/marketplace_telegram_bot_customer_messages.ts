import { growio } from "../growio";
import { IdParam } from "../types";

export const apiMarketplaceTelegramBotCustomerMessagesCreate = (params: {
  customer_id: IdParam;
  text: string;
}) =>
  growio
    .post(
      `/api/marketplace/telegram_bot/customers/${params.customer_id}/messages`,
      params
    )
    .then((r) => r.data);
