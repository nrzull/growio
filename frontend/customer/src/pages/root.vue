<template>
  <PageLoader :loading="isLoading" />

  <PageShape v-if="payload">
    <template #heading>{{ payload.marketplace.name }}</template>
    <template v-if="payload.marketplace.address" #subheading>
      {{ payload.marketplace.address }}
    </template>

    <Inventory :items="payload.items" />
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { useRoute } from "vue-router";
import { apiCustomersGetMarketplacePayload } from "@growio/shared/api/growio/customers";
import { wait, Wait } from "@growio/shared/composables/wait";
import { MarketplacePayload } from "@growio/shared/api/growio/customers/types";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import Inventory from "~/components/Inventory.vue";

const route = useRoute();

const payload = ref<MarketplacePayload>();

const isLoading = computed(() => wait.some([Wait.MARKETPLACE_PAYLOAD_FETCH]));

const fetchPayload = async () => {
  try {
    wait.start(Wait.MARKETPLACE_PAYLOAD_FETCH);

    payload.value = await apiCustomersGetMarketplacePayload(
      route.params.payload as string
    );
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_PAYLOAD_FETCH);
  }
};

fetchPayload();
</script>
