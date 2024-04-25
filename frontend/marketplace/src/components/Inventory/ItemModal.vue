<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceItem(modelValue)" #heading>
      <span>{{ modelValue.name }}</span> <Tag size="sm">Item</Tag>
    </template>
    <template v-else #heading> Create item </template>

    <div :class="$style.row">
      <TextInput v-model="item.name" placeholder="Name" />
      <TextInput
        v-model="item.price"
        :placeholder="`Price ${currency ? `(${currency})` : ''}`"
      />
      <SelectInput
        v-model="category"
        :readonly="isMarketplaceItem(modelValue)"
        placeholder="Category"
        track-by="id"
        label-path="name"
        :items="categories"
      />
    </div>

    <div :class="$style.row">
      <TextInput v-model="item.quantity" placeholder="Quantity" />
      <TextInput v-model="item.description" placeholder="Description" />
    </div>

    <Dropzone
      v-model:output="assetsOutput"
      v-model:output-create="assetsOutputCreate"
      v-model:output-delete="assetsOutputDelete"
      :input="assetsInput"
    />

    <template #footer>
      <Button size="md" @click="submit">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref, watch } from "vue";
import Modal from "@growio/shared/components/Modal.vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import SelectInput from "@growio/shared/components/SelectInput.vue";
import Button from "@growio/shared/components/Button.vue";
import { MarketplaceItemCategory } from "@growio/shared/api/growio/marketplace_item_categories/types";
import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "@growio/shared/api/growio/marketplace_items/types";
import { apiMarketplaceItemCategoriesGetAll } from "@growio/shared/api/growio/marketplace_item_categories";
import { clone } from "remeda";
import { Wait, wait } from "@growio/shared/composables/wait";
import { isMarketplaceItem } from "@growio/shared/api/growio/marketplace_items/utils";
import Tag from "@growio/shared/components/Tag.vue";
import Dropzone from "@growio/shared/components/Dropzone.vue";
import { apiMarketplaceItemAssetsGetAll } from "@growio/shared/api/growio/marketplace_item_assets";
import {
  MarketplaceItemAsset,
  PartialMarketplaceItemAsset,
} from "@growio/shared/api/growio/marketplace_item_assets/types";
import { marketplaceAccount } from "~/composables/marketplace-accounts";

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
  submit: (_v: {
    item: PartialMarketplaceItem | MarketplaceItem;
    assetsDelete: MarketplaceItemAsset[];
    assetsCreate: PartialMarketplaceItemAsset[];
  }) => true,
});

const assetsInput = ref<
  Array<MarketplaceItemAsset | PartialMarketplaceItemAsset>
>([]);
const assetsOutput = ref<
  Array<MarketplaceItemAsset | PartialMarketplaceItemAsset>
>([]);
const assetsOutputCreate = ref<Array<PartialMarketplaceItemAsset>>([]);
const assetsOutputDelete = ref<Array<MarketplaceItemAsset>>([]);

const item = ref<PartialMarketplaceItem | MarketplaceItem>(
  clone(props.modelValue)
);
const category = ref<MarketplaceItemCategory>();
const categories = ref<MarketplaceItemCategory[]>([]);

const currency = computed(() => marketplaceAccount.value.marketplace.currency);

const isLoading = computed(
  () =>
    props.loading ||
    wait.some([
      Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH,
      Wait.MARKETPLACE_ITEM_ASSETS_FETCH,
    ])
);

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

const fetchAssets = async () => {
  if (!isMarketplaceItem(props.modelValue)) {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_ITEM_ASSETS_FETCH);
    assetsInput.value = await apiMarketplaceItemAssetsGetAll({
      category_id: props.modelValue.category_id,
      item_id: props.modelValue.id,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_ASSETS_FETCH);
  }
};

const submit = () => {
  emit("submit", {
    item: item.value,
    assetsCreate: assetsOutputCreate.value,
    assetsDelete: assetsOutputDelete.value,
  });
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
fetchAssets();
</script>

<style module>
.row {
  display: flex;
  gap: 8px;
}
</style>
