import { MarketplaceTreeItem } from "../marketplace_items_tree/types";
import { Currency } from "../../../utils/money";

export type MarketplaceOrder = {
  id: string;
  status: "init" | "need_payment" | "done" | "cancelled";
  payload: {
    items?: MarketplaceTreeItem[];
    currency?: Currency;
  };
  marketplace_id: number;
  telegram_bot_customer_id?: number;
};
