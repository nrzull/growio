<template>
  <Modal @close="$emit('close')">
    <template #heading>Create Item</template>

    <ElementLoader :loading="isLoading" />

    <div :class="$style.row">
      <TextInput v-model="item.name" placeholder="Name" />
      <SelectInput
        v-model="category"
        placeholder="Category"
        track-by="id"
        label-path="name"
        :items="categories"
      />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', item)">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref, watch } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import SelectInput from "~/components/SelectInput.vue";
import Button from "~/components/Button.vue";
import { MarketplaceItemCategory } from "~/api/growio/marketplace_item_categories/types";
import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "~/api/growio/marketplace_items/types";
import { apiMarketplaceItemCategoriesGetAll } from "~/api/growio/marketplace_item_categories";
import { clone } from "remeda";
import ElementLoader from "~/components/ElementLoader.vue";
import { Wait, wait } from "~/composables/wait";

const props = defineProps({
  modelValue: {
    type: Object as PropType<PartialMarketplaceItem | MarketplaceItem>,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits({
  close: () => true,
  submit: (_v: PartialMarketplaceItem | MarketplaceItem) => true,
});

const item = ref<PartialMarketplaceItem | MarketplaceItem>(
  clone(props.modelValue)
);
const category = ref<MarketplaceItemCategory>();
const categories = ref<MarketplaceItemCategory[]>([]);

const isLoading = computed(() => props.loading || wait.some([]));

const fetchCategories = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH);

    categories.value = await apiMarketplaceItemCategoriesGetAll({
      deleted_at: false,
    });

    if (item.value.category_id) {
      category.value = categories.value.find(
        (v) => v.id === item.value.category_id
      );
    }
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH);
  }
};

watch(
  category,
  (v) => {
    if (v) {
      item.value.category_id = v.id;
    }
  },
  { deep: true }
);

fetchCategories();
</script>

<style module>
.row {
  display: flex;
  gap: 8px;
}
</style>
