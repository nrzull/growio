import { ref } from "vue";
import { MarketplaceAccount } from "~/api/growio/marketplace_accounts/types";

export const marketplaceAccounts = ref<MarketplaceAccount[]>([]);
