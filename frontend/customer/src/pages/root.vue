<template>
  <PageLoader :loading="isLoading" />

  <PageShape v-if="payload">
    <template #heading>{{ payload.marketplace.name }}</template>
    <template v-if="payload.marketplace.address" #subheading>
      {{ payload.marketplace.address }}
    </template>

    <template #tools>
      <Button
        v-if="selectedItems.length"
        size="md"
        icon="cart"
        @click="$router.push(`/${payloadKey}/cart`)"
      >
        {{ selectedItems.length }}
      </Button>
    </template>

    <RouterView v-slot="{ Component }">
      <component
        :is="Component"
        :loading="isLoading"
        :payload-key="payloadKey"
        v-model:payload="payload"
        v-model:selected-items="selectedItems"
      />
    </RouterView>
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

import { useLocalStorage } from "@vueuse/core";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";
import Button from "@growio/shared/components/Button.vue";

const route = useRoute();
const payloadKey = route.params.payload as string;
const payload = ref<MarketplacePayload>();
const selectedItems = useLocalStorage<MarketplaceItem[]>(payloadKey, []);

const isLoading = computed(() => wait.some([Wait.MARKETPLACE_PAYLOAD_FETCH]));

const fetchPayload = async () => {
  try {
    wait.start(Wait.MARKETPLACE_PAYLOAD_FETCH);

    payload.value = await apiCustomersGetMarketplacePayload(payloadKey);
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_PAYLOAD_FETCH);
  }
};

fetchPayload();
</script>
