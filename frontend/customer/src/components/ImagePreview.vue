<template>
  <div
    :class="[
      $style.itemImageWrapper,
      {
        [$style.empty]: !modelValue.assets.at(0),
      },
    ]"
  >
    <img
      v-if="modelValue.assets.at(0)"
      :class="$style.itemImage"
      :src="modelValue.assets.at(0).src"
    />
    <Icon v-else value="imageRect" size="lg" />
  </div>
</template>

<script setup lang="ts">
import { MarketplaceTreeItem } from "@growio/shared/api/growio/marketplace_items_tree/types";
import Icon from "@growio/shared/components/Icon.vue";
import { PropType } from "vue";

defineProps({
  modelValue: {
    type: Object as PropType<MarketplaceTreeItem>,
    required: true,
  },
});
</script>

<style module>
.itemImageWrapper {
  width: 100%;
  height: 200px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.itemImageWrapper.empty {
  background-color: var(--color-gray-50);
  border-radius: 8px;
}

.itemImage {
  width: 100%;
  height: 100%;
  object-fit: contain;
}
</style>
