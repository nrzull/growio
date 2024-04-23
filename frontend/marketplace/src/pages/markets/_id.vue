<template>
  <MarketModal
    v-if="marketModal"
    :loading="isLoading"
    :model-value="marketModal"
    @close="marketModal = undefined"
    @submit="updateMarket"
  />

  <RouterView v-slot="{ Component }">
    <component
      :is="Component"
      v-if="market"
      :loading="isLoading"
      :market="market"
      @update:market="fetchMarket"
    >
      <template #tabs>
        <Tabs>
          <Button
            type="neutral"
            size="md"
            icon="editRegular"
            :active="!!marketModal"
            @click="marketModal = market"
          >
            {{ market?.address }}
          </Button>

          <RouterLink
            v-slot="{ navigate, isActive }"
            custom
            :to="`/markets/${marketId}/items`"
          >
            <Button
              type="neutral"
              size="md"
              :active="isActive"
              @click="navigate"
            >
              Items
            </Button>
          </RouterLink>

          <RouterLink
            v-slot="{ navigate, isActive }"
            custom
            :to="`/markets/${marketId}/integrations`"
          >
            <Button
              type="neutral"
              size="md"
              :active="isActive"
              @click="navigate"
            >
              Integrations
            </Button>
          </RouterLink>
        </Tabs>
      </template>
    </component>
  </RouterView>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import {
  apiMarketplaceMarketsGetOne,
  apiMarketplaceMarketsUpdate,
} from "@growio/shared/api/growio/marketplace_markets";
import { MarketplaceMarket } from "@growio/shared/api/growio/marketplace_markets/types";
import { wait, Wait } from "@growio/shared/composables/wait";
import { useRoute } from "vue-router";
import Button from "@growio/shared/components/Button.vue";
import MarketModal from "~/components/Inventory/MarketModal.vue";
import Tabs from "@growio/shared/components/Tabs.vue";

const route = useRoute();

const market = ref<MarketplaceMarket>();
const marketId = computed(() => route.params.id as string);
const marketModal = ref<MarketplaceMarket>();

const isLoading = computed(() => wait.some([Wait.MARKETPLACE_MARKET_FETCH]));

const fetchMarket = async () => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_FETCH);
    market.value = await apiMarketplaceMarketsGetOne({
      market_id: marketId.value,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_FETCH);
  }
};

const updateMarket = async (params: MarketplaceMarket) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_UPDATE);
    await apiMarketplaceMarketsUpdate(params);
    await fetchMarket();
    marketModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_UPDATE);
  }
};

fetchMarket();
</script>
