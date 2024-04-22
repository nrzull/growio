<template>
  <div :class="$style.loader">
    <LoaderIcon />
  </div>
</template>

<script setup lang="ts">
import { apiMarketplaceAccountsGetSelf } from "@growio/shared/api/growio/marketplace_accounts";
import { account } from "~/composables/account";
import { apiMarketplacesCreate } from "@growio/shared/api/growio/marketplaces";
import { useRouter, useRoute } from "vue-router";
import LoaderIcon from "@growio/shared/components/LoaderIcon.vue";

const router = useRouter();
const route = useRoute();

const redirect = () => router.push((route.query.to as string) || "/");

(async () => {
  const accounts = await apiMarketplaceAccountsGetSelf();

  if (accounts.length) {
    redirect();
  } else {
    await apiMarketplacesCreate({ name: account.value.email });
    redirect();
  }
})();
</script>

<style module>
.loader {
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>
