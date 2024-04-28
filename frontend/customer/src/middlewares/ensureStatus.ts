import { MarketplaceOrder } from "@growio/shared/api/growio/marketplace_orders/types";
import { RouteLocationRaw } from "vue-router";
import { payload } from "~/composables/payload";

export const ensureSomeStatus = (
  statuses: Array<MarketplaceOrder["status"]>,
  redirect: RouteLocationRaw
) => {
  if (!statuses.some((status) => status === payload.value.order.status)) {
    return redirect;
  }
};

export const ensureNotSomeStatus = (
  statuses: Array<MarketplaceOrder["status"]>,
  redirect: RouteLocationRaw
) => {
  if (statuses.some((status) => status === payload.value.order.status)) {
    return redirect;
  }
};
