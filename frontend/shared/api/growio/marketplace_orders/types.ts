import { MarketplaceTreeItem } from "../marketplace_items_tree/types";
import { Currency } from "../../../utils/money";

export type MarketplaceOrder = {
  id: string;
  status:
    | "init"
    | "need_payment"
    | "preparing"
    | "can_be_taken"
    | "can_be_delivered"
    | "delivering"
    | "done"
    | "cancelled";
  items?: MarketplaceTreeItem[];
  currency?: Currency;
  payment_type?: "online" | "in_place";
  payment_provider?: "system";
  delivery_type?: "export" | "self_export";
  delivery_provider?: "merchant";
  delivery_address?: string;
  marketplace_id: number;
  telegram_bot_customer_id?: number;
};
