import {
  MarketplaceWarehouse,
  PartialMarketplaceWarehouse,
} from "~/api/growio/marketplace_warehouses/types";
import { growio } from "~/api/growio";

export const apiMarketplaceWarehousesGetAll = () =>
  growio
    .get<MarketplaceWarehouse[]>("/api/marketplace_warehouses")
    .then((r) => r.data);

export const apiMarketplaceWarehousesCreate = (
  params: PartialMarketplaceWarehouse
) =>
  growio
    .post<MarketplaceWarehouse>("/api/marketplace_warehouses", params)
    .then((r) => r.data);

export const apiMarketplaceWarehousesUpdate = (params: MarketplaceWarehouse) =>
  growio
    .patch<MarketplaceWarehouse>(
      `/api/marketplace_warehouses/${params.id}`,
      params
    )
    .then((r) => r.data);
