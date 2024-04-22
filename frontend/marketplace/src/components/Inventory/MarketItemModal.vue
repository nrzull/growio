<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceMarketItem(modelValue)" #heading>
      <span>{{ modelValue.marketplace_item.name }}</span>
      <Tag>Market Item</Tag>
    </template>
    <template v-else #heading> Create Market Item </template>

    <div :class="$style.row">
      <SelectInput
        v-model="selectedItem"
        :items="items"
        :readonly="isMarketplaceMarketItem(modelValue)"
        track-by="id"
        label-path="name"
        placeholder="Item"
      />
      <TextInput v-model="marketItem.quantity" placeholder="Quantity" />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', marketItem)">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref, watch } from "vue";
import Modal from "@growio/shared/components/Modal.vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import SelectInput from "@growio/shared/components/SelectInput.vue";
import Button from "@growio/shared/components/Button.vue";
import { isMarketplaceMarketItem } from "@growio/shared/api/growio/marketplace_market_items/utils";
import { wait, Wait } from "@growio/shared/composables/wait";
import { clone } from "remeda";
import Tag from "@growio/shared/components/Tag.vue";
import {
  MarketplaceMarketItem,
  PartialMarketplaceMarketItem,
} from "@growio/shared/api/growio/marketplace_market_items/types";
import { apiMarketplaceItemsSelfGetAll } from "@growio/shared/api/growio/marketplace_items";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";

const props = defineProps({
  modelValue: {
    type: Object as PropType<
      PartialMarketplaceMarketItem | MarketplaceMarketItem
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

const marketItem = ref<PartialMarketplaceMarketItem | MarketplaceMarketItem>(
  clone(props.modelValue)
);

const selectedItem = ref<MarketplaceItem>();

watch(
  selectedItem,
  (v) => {
    marketItem.value.marketplace_item_id = v.id;
  },
  { deep: true }
);

const items = ref<MarketplaceItem[]>([]);

const emit = defineEmits({
  close: () => true,
  submit: (_v: PartialMarketplaceMarketItem | MarketplaceMarketItem) => true,
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

if (isMarketplaceMarketItem(marketItem.value)) {
  selectedItem.value = marketItem.value.marketplace_item;
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
