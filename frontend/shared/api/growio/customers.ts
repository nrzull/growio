import { growio } from "@growio/shared/api/growio";
import { MarketplacePayload } from "./customers/types";
import { MarketplaceOrder } from "./marketplace_orders/types";
import { MarketplaceItem } from "./marketplace_items/types";

export const apiCustomersGetMarketplacePayload = (params: string) =>
  growio
    .get<MarketplacePayload>(`/api/customers/marketplace/payload/${params}`)
    .then((r) => r.data);

export const apiCustomersUpdateMarketplacePayload = (params: {
  key: string;
  payload: {
    items: Array<Pick<MarketplaceItem, "id" | "name" | "price" | "quantity">>;
    status: MarketplaceOrder["status"];
  };
}) =>
  growio
    .patch<MarketplacePayload>(
      `/api/customers/marketplace/payload/${params.key}`,
      params.payload
    )
    .then((r) => r.data);
