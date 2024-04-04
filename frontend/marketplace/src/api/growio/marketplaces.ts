import { Marketplace } from "~/api/growio/marketplaces/types";
import { growio } from "~/api/growio";

export const apiMarketplacesCreate = (params: { name: string }) =>
  growio.post<Marketplace>("/api/marketplaces", params).then((r) => r.data);
