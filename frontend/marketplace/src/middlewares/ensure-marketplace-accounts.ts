import {
  marketplaceAccounts,
  fetchMarketplaceAccounts,
} from "~/composables/marketplace-accounts";
import { RouteLocationNormalized } from "vue-router";

export const ensureMarketplaceAccounts = async (
  to: RouteLocationNormalized
) => {
  await fetchMarketplaceAccounts();

  if (!marketplaceAccounts.value.length) {
    return {
      path: "/setup",
      query: { to: to.fullPath },
    };
  }
};
