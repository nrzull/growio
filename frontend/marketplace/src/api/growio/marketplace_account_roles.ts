import { growio } from "~/api/growio";
import {
  MarketplaceAccountRole,
  PartialMarketplaceAccountRole,
} from "~/api/growio/marketplace_account_roles/types";

export const apiMarketplaceAccountRolesGetAll = (
  params: { deleted_at?: boolean } = { deleted_at: false }
) =>
  growio
    .get<MarketplaceAccountRole[]>("/api/marketplace_account_roles", { params })
    .then((r) => r.data);

export const apiMarketplaceAccountRolesCreate = (
  params: PartialMarketplaceAccountRole
) =>
  growio
    .post<MarketplaceAccountRole>("/api/marketplace_account_roles", params)
    .then((r) => r.data);

export const apiMarketplaceAccountRolesUpdate = (
  params: MarketplaceAccountRole
) =>
  growio
    .patch<MarketplaceAccountRole>(
      `/api/marketplace_account_roles/${params.id}`,
      params
    )
    .then((r) => r.data);

export const apiMarketplaceAccountRolesDelete = (
  params: MarketplaceAccountRole
) => growio.delete(`/api/marketplace_account_roles/${params.id}`);
