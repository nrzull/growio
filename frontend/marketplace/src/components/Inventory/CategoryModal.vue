<template>
  <Modal @close="$emit('close')">
    <template v-if="isMarketplaceItemCategory(modelValue)" #heading>
      <span>{{ modelValue.name }}</span> <Tag>Category</Tag>
    </template>
    <template v-else #heading> Create Category </template>

    <template #loader>
      <ElementLoader :loading="isLoading" />
    </template>

    <div :class="$style.row">
      <TextInput v-model="category.name" placeholder="Name" />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', category)">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import Button from "~/components/Button.vue";
import {
  PartialMarketplaceItemCategory,
  MarketplaceItemCategory,
} from "~/api/growio/marketplace_item_categories/types";
import { isMarketplaceItemCategory } from "~/api/growio/marketplace_item_categories/utils";
import ElementLoader from "~/components/ElementLoader.vue";
import { clone } from "remeda";
import Tag from "~/components/Tag.vue";

const props = defineProps({
  modelValue: {
    type: Object as PropType<
      PartialMarketplaceItemCategory | MarketplaceItemCategory
    >,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const isLoading = computed(() => props.loading);

const category = ref<PartialMarketplaceItemCategory | MarketplaceItemCategory>(
  clone(props.modelValue)
);

const emit = defineEmits({
  close: () => true,
  submit: (_v: PartialMarketplaceItemCategory | MarketplaceItemCategory) =>
    true,
});
</script>

<style module>
.row {
  display: grid;
  gap: 8px;
}
</style>
