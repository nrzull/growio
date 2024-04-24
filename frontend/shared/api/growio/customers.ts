import { growio } from "@growio/shared/api/growio";
import { MarketplacePayload } from "./customers/types";

export const apiCustomersGetMarketplacePayload = (params: string) =>
  growio
    .get<MarketplacePayload>(`/api/customers/marketplace/payload/${params}`)
    .then((r) => r.data);
