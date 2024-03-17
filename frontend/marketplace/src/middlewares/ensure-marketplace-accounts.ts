import { apiMarketplaceAccountsGetSelf } from "~/api/growio";
import { marketplaceAccounts } from "~/composables/marketplace-accounts";
import { RouteLocationNormalized } from "vue-router";

export const ensureMarketplaceAccounts = async (
  to: RouteLocationNormalized
) => {
  if (marketplaceAccounts.value.length) {
    return;
  }

  try {
    marketplaceAccounts.value = await apiMarketplaceAccountsGetSelf();

    if (!marketplaceAccounts.value.length) {
      return {
        path: "/setup",
        query: { to: to.fullPath },
      };
    }
  } catch (e) {
    console.error(e);
  }
};
