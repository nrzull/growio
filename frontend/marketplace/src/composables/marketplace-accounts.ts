import { ref } from "vue";
import { MarketplaceAccountRaw } from "~/api/growio/types";

export const marketplaceAccounts = ref<MarketplaceAccountRaw[]>([]);
