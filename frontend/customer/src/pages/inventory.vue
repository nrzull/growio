<template>
  <Inventory :items="payload.items" v-model="proxySelectedItems" />
</template>

<script setup lang="ts">
import { defineModel } from "vue";
import Inventory from "~/components/Inventory.vue";
import { MarketplacePayload } from "@growio/shared/api/growio/customers/types";
import { PropType } from "vue";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";

defineOptions({ inheritAttrs: false });

defineProps({
  payload: {
    type: Object as PropType<MarketplacePayload>,
  },

  selectedItems: {
    type: Array as PropType<MarketplaceItem[]>,
    default: () => [],
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const proxySelectedItems = defineModel<MarketplaceItem[]>("selectedItems", {
  default: [],
});
</script>
