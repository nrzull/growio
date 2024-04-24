<template>
  <PageLoader :loading="isLoading" />

  <PageShape>
    <template #heading> General </template>

    <div :class="$style.body">
      <div :class="$style.grid">
        <div :class="$style.row">
          <TextInput v-model="model.name" placeholder="Name" />
          <SelectInput
            v-model="model.currency"
            placeholder="Currency"
            :items="currencyOptions"
          />
        </div>
        <div :class="$style.row">
          <TextInput v-model="model.address" placeholder="Address" />
        </div>
      </div>

      <Button :disabled="isLoading" @click="updateMarketplace">Save</Button>
    </div>
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { wait, Wait } from "@growio/shared/composables/wait";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import SelectInput from "@growio/shared/components/SelectInput.vue";
import Button from "@growio/shared/components/Button.vue";
import {
  marketplaceAccount,
  fetchActiveMarketplaceAccount,
} from "~/composables/marketplace-accounts";
import { Marketplace } from "@growio/shared/api/growio/marketplaces/types";
import { apiMarketplaceUpdate } from "@growio/shared/api/growio/marketplaces";
import { clone } from "remeda";

const currencyOptions = ["RUB", "KGS"];
const model = ref<Marketplace>(clone(marketplaceAccount.value.marketplace));

const isLoading = computed(() => wait.some([Wait.MARKETPLACE_UPDATE]));

const updateMarketplace = async () => {
  try {
    wait.start(Wait.MARKETPLACE_UPDATE);
    await apiMarketplaceUpdate(model.value);
    await fetchActiveMarketplaceAccount();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_UPDATE);
  }
};
</script>

<style module>
.row {
  display: flex;
  gap: 8px;
}

.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}

.body {
  display: flex;
  flex-flow: column;
  justify-content: space-between;
  height: 100%;
  gap: 24px;
}
</style>
