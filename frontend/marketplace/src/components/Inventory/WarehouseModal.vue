<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceWarehouse(modelValue)" #heading>
      <span>{{ modelValue.name }}</span> <Tag>Warehouse</Tag>
    </template>
    <template v-else #heading> Create Warehouse </template>

    <div :class="$style.row">
      <TextInput v-model="warehouse.name" placeholder="Name" />
      <TextInput v-model="warehouse.address" placeholder="Address" />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', warehouse)">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import Button from "~/components/Button.vue";
import { isMarketplaceWarehouse } from "~/api/growio/marketplace_warehouses/utils";
import { clone } from "remeda";
import Tag from "~/components/Tag.vue";
import {
  MarketplaceWarehouse,
  PartialMarketplaceWarehouse,
} from "~/api/growio/marketplace_warehouses/types";

const props = defineProps({
  modelValue: {
    type: Object as PropType<
      PartialMarketplaceWarehouse | MarketplaceWarehouse
    >,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const isLoading = computed(() => props.loading);

const warehouse = ref<PartialMarketplaceWarehouse | MarketplaceWarehouse>(
  clone(props.modelValue)
);

const emit = defineEmits({
  close: () => true,
  submit: (_v: PartialMarketplaceWarehouse | MarketplaceWarehouse) => true,
});
</script>

<style module>
.row {
  display: grid;
  gap: 8px;
  grid-template-columns: 1fr 1fr;
}
</style>
