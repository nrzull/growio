<template>
  <PromiseModal ref="deleteItemModalRef">
    <template #heading>Delete item from cart</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <Tabs>
    <Button
      size="md"
      type="neutral"
      @click="$router.push(`/${payloadKey}`)"
      icon="arrowBack"
    >
    </Button>
    <Button size="md" type="neutral" active icon="cart">Cart</Button>
  </Tabs>

  <Notification
    v-if="!selectedItems.length"
    :model-value="{ text: 'There is no items in cart', type: 'error' }"
  />
  <template v-else>
    <Table :table headless>
      <template #quantity="{ ctx }">
        {{ ctx.row.original.quantity }}
      </template>

      <template #actions="{ ctx }">
        <Button
          type="neutral"
          size="sm"
          icon="plus"
          @click.stop="increment(ctx.row.original)"
        ></Button>
        <Button
          type="neutral"
          size="sm"
          icon="minusCircle"
          @click.stop="decrement(ctx.row.original)"
        ></Button>
      </template>
    </Table>

    <Button :disabled="!hasQuantity">Checkout</Button>
  </template>
</template>

<script setup lang="ts">
import { MarketplacePayload } from "@growio/shared/api/growio/customers/types";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";
import { PropType, computed, ref } from "vue";
import Tabs from "@growio/shared/components/Tabs.vue";
import Button from "@growio/shared/components/Button.vue";
import Table from "@growio/shared/components/Table.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import Notification from "@growio/shared/components/Notifications/Notification.vue";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  payload: {
    type: Object as PropType<MarketplacePayload>,
  },

  payloadKey: {
    type: String,
    required: true,
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

const emit = defineEmits(["update:selected-items"]);

const deleteItemModalRef = ref<InstanceType<typeof PromiseModal>>();

const proxySelectedItems = computed({
  get: () => props.selectedItems,
  set: (v) => emit("update:selected-items", v),
});

const columnHelper = createColumnHelper<MarketplaceItem>();

const columns = ref([
  columnHelper.accessor("name", {
    cell: (info) => info.getValue(),
    header: () => "Name",
  }),

  columnHelper.display({
    id: "quantity",
    meta: { style: { "text-align": "right" } },
  }),

  columnHelper.display({ id: "actions", meta: { style: { width: "0" } } }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return proxySelectedItems.value;
  },

  get columns() {
    return columns.value;
  },
});

const hasQuantity = computed(() =>
  proxySelectedItems.value.some((v) => v.quantity)
);

const increment = (item: MarketplaceItem) => {
  const foundItem = proxySelectedItems.value.find((i) => i.id === item.id);

  if (foundItem) {
    foundItem.quantity += 1;
  }
};

const decrement = async (item: MarketplaceItem) => {
  const foundItem = proxySelectedItems.value.find((i) => i.id === item.id);

  if (foundItem && foundItem.quantity >= 1) {
    foundItem.quantity -= 1;
    return;
  }

  try {
    await deleteItemModalRef.value?.confirm();
  } catch {
    return;
  }

  proxySelectedItems.value = proxySelectedItems.value.filter(
    (v) => v.id !== item.id
  );
};
</script>
