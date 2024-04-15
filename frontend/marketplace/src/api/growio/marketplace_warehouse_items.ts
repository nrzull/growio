import {
  MarketplaceWarehouseItem,
  PartialMarketplaceWarehouseItem,
} from "~/api/growio/marketplace_warehouse_items/types";
import { growio } from "~/api/growio";
import { IdParam } from "~/api/types";

export const apiMarketplaceWarehouseItemsGetAll = (params: {
  warehouse_id: IdParam;
}) =>
  growio
    .get<MarketplaceWarehouseItem[]>(
      `/api/marketplace_warehouses/${params.warehouse_id}/marketplace_warehouse_items`
    )
    .then((r) => r.data);

export const apiMarketplaceWarehouseItemsCreate = (params: {
  warehouse_id: IdParam;
  item: PartialMarketplaceWarehouseItem;
}) =>
  growio
    .post<MarketplaceWarehouseItem>(
      `/api/marketplace_warehouses/${params.warehouse_id}/marketplace_warehouse_items`,
      params.item
    )
    .then((r) => r.data);
