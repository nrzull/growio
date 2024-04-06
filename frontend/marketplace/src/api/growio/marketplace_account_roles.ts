import { growio } from "~/api/growio";
import { MarketplaceAccountRole } from "~/api/growio/marketplace_account_roles/types";
import { IdParam } from "~/api/types";
import { PartialMarketplaceAccountRole } from "~/components/Roles/types";

export const apiMarketplaceAccountRolesGetAll = (
  params: { deleted_at?: boolean } = {}
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
