<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceWarehouseItem(modelValue)" #heading>
      <span>{{ modelValue.marketplace_item.name }}</span>
      <Tag>Warehouse Item</Tag>
    </template>
    <template v-else #heading> Create Warehouse Item </template>

    <div :class="$style.row">
      <TextInput v-model="warehouseItem.quantity" placeholder="Quantity" />
      <SelectInput
        v-model="selectedItem"
        :items="items"
        :readonly="isMarketplaceWarehouseItem(modelValue)"
        track-by="id"
        label-path="name"
        placeholder="Item"
      />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', warehouseItem)">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref, watch } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import SelectInput from "~/components/SelectInput.vue";
import Button from "~/components/Button.vue";
import { isMarketplaceWarehouseItem } from "~/api/growio/marketplace_warehouse_items/utils";
import { wait, Wait } from "~/composables/wait";
import { clone } from "remeda";
import Tag from "~/components/Tag.vue";
import {
  MarketplaceWarehouseItem,
  PartialMarketplaceWarehouseItem,
} from "~/api/growio/marketplace_warehouse_items/types";
import { apiMarketplaceItemsSelfGetAll } from "~/api/growio/marketplace_items";
import { MarketplaceItem } from "~/api/growio/marketplace_items/types";

const props = defineProps({
  modelValue: {
    type: Object as PropType<
      PartialMarketplaceWarehouseItem | MarketplaceWarehouseItem
    >,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const isLoading = computed(
  () => props.loading || wait.some([Wait.MARKETPLACE_ITEMS_FETCH])
);

const warehouseItem = ref<
  PartialMarketplaceWarehouseItem | MarketplaceWarehouseItem
>(clone(props.modelValue));

const selectedItem = ref<MarketplaceItem>();

watch(
  selectedItem,
  (v) => {
    warehouseItem.value.marketplace_item_id = v.id;
  },
  { deep: true }
);

const items = ref<MarketplaceItem[]>([]);

const emit = defineEmits({
  close: () => true,
  submit: (_v: PartialMarketplaceWarehouseItem | MarketplaceWarehouseItem) =>
    true,
});

const fetchItems = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ITEMS_FETCH);
    items.value = await apiMarketplaceItemsSelfGetAll({ deleted_at: false });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEMS_FETCH);
  }
};

if (isMarketplaceWarehouseItem(warehouseItem.value)) {
  selectedItem.value = warehouseItem.value.marketplace_item;
}

fetchItems();
</script>

<style module>
.row {
  display: grid;
  gap: 8px;
  grid-template-columns: 1fr 1fr;
}
</style>
