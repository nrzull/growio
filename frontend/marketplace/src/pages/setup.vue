<template>
  <LoaderPage />
</template>

<script setup lang="ts">
import LoaderPage from "~/components/loader-page.vue";
import { apiMarketplaceAccountsGetSelf } from "~/api/growio/marketplace_accounts";
import { account } from "~/composables/account";
import { apiMarketplacesCreate } from "~/api/growio/marketplaces";
import { useRouter, useRoute } from "vue-router";

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
