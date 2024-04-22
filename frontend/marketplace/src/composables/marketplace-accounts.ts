import { ref } from "vue";
import {
  apiMarketplaceAccountsGetSelfActive,
  apiMarketplaceAccountsGetSelf,
} from "@growio/shared/api/growio/marketplace_accounts";
import { MarketplaceAccount } from "@growio/shared/api/growio/marketplace_accounts/types";

export const marketplaceAccounts = ref<MarketplaceAccount[]>([]);

export const marketplaceAccount = ref<MarketplaceAccount>();

export const fetchMarketplaceAccounts = async () => {
  try {
    marketplaceAccounts.value = await apiMarketplaceAccountsGetSelf();
  } catch (e) {
    console.error(e);
  }
};

export const fetchActiveMarketplaceAccount = async () => {
  try {
    marketplaceAccount.value = await apiMarketplaceAccountsGetSelfActive();
  } catch (e) {
    console.error(e);
  }
};
