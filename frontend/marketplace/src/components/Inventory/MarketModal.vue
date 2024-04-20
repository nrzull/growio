<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceMarket(modelValue)" #heading>
      <span>{{ modelValue.address }}</span> <Tag>Market</Tag>
    </template>
    <template v-else #heading> Create Market </template>

    <div :class="$style.row">
      <TextInput v-model="market.address" placeholder="Address" />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', market)">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import Button from "~/components/Button.vue";
import { isMarketplaceMarket } from "~/api/growio/marketplace_markets/utils";
import { clone } from "remeda";
import Tag from "~/components/Tag.vue";
import {
  MarketplaceMarket,
  PartialMarketplaceMarket,
} from "~/api/growio/marketplace_markets/types";

const props = defineProps({
  modelValue: {
    type: Object as PropType<PartialMarketplaceMarket | MarketplaceMarket>,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const isLoading = computed(() => props.loading);

const market = ref<PartialMarketplaceMarket | MarketplaceMarket>(
  clone(props.modelValue)
);

const emit = defineEmits({
  close: () => true,
  submit: (_v: PartialMarketplaceMarket | MarketplaceMarket) => true,
});
</script>

<style module>
.row {
  display: flex;
  gap: 8px;
}
</style>
