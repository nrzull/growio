<template>
  <PageLoader :loading="isLoading" />

  <PageShape>
    <template #heading> General </template>

    <div :class="$style.body">
      <div :class="$style.grid">
        <div :class="$style.row">
          <TextInput placeholder="Name" v-model="model.name" />
          <SelectInput
            placeholder="Currency"
            :items="currencyOptions"
            v-model="model.currency"
          />
        </div>
      </div>

      <Button :disabled="isLoading" @click="updateMarketplace">Save</Button>
    </div>
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { wait, Wait } from "~/composables/wait";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import TextInput from "~/components/TextInput.vue";
import SelectInput from "~/components/SelectInput.vue";
import Button from "~/components/Button.vue";
import {
  marketplaceAccount,
  fetchActiveMarketplaceAccount,
} from "~/composables/marketplace-accounts";
import { Marketplace } from "~/api/growio/marketplaces/types";
import { apiMarketplacesUpdateSelf } from "~/api/growio/marketplaces";
import { clone } from "remeda";

const currencyOptions = ["RUB", "KGS"];
const model = ref<Marketplace>(clone(marketplaceAccount.value.marketplace));

const isLoading = computed(() => wait.some([Wait.MARKETPLACE_UPDATE]));

const updateMarketplace = async () => {
  try {
    wait.start(Wait.MARKETPLACE_UPDATE);
    await apiMarketplacesUpdateSelf(model.value);
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
  display: grid;
  grid-template-columns: 1fr 1fr;
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
