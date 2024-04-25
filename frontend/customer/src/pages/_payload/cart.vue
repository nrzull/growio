<template>
  <PromiseModal ref="deleteItemModalRef">
    <template #heading>Delete item from cart</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <PageShape>
    <template #heading>
      <slot name="heading"></slot>
    </template>

    <template #subheading>
      <slot name="subheading"></slot>
    </template>

    <Tabs>
      <Button
        size="md"
        type="neutral"
        icon="arrowBack"
        @click="$router.push(`/${payloadKey}/categories`)"
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
        <template #price="{ ctx }">
          <template v-if="ctx.row.original.price && ctx.row.original.quantity">
            {{
              formatPrice({
                currency: payload.marketplace.currency,
                price: ctx.row.original.price,
                quantity: ctx.row.original.quantity,
              })
            }}
          </template>
        </template>

        <template #quantity="{ ctx }">
          <template v-if="ctx.row.original.quantity">
            {{ ctx.row.original.quantity }}
          </template>
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

      <Button :disabled="!hasQuantity">
        Checkout

        <template v-if="totalPrice">{{
          formatPrice({
            price: String(totalPrice),
            currency: payload.marketplace.currency,
            quantity: 1,
          })
        }}</template>
      </Button>
    </template>
  </PageShape>
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
import { useRoute } from "vue-router";
import { useLocalStorage } from "@vueuse/core";
import PageShape from "@growio/shared/components/PageShape.vue";
import { formatPrice } from "@growio/shared/utils/money";

defineOptions({ inheritAttrs: false });

defineProps({
  loading: {
    type: Boolean,
    default: false,
  },

  payload: {
    type: Object as PropType<MarketplacePayload>,
    required: true,
  },
});

const route = useRoute();
const payloadKey = route.params.payload as string;
const selectedItems = useLocalStorage<MarketplaceItem[]>(payloadKey, []);

const deleteItemModalRef = ref<InstanceType<typeof PromiseModal>>();

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

  columnHelper.display({
    id: "price",
    meta: { style: { width: "0", "text-align": "right" } },
  }),

  columnHelper.display({ id: "actions", meta: { style: { width: "0" } } }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return selectedItems.value;
  },

  get columns() {
    return columns.value;
  },
});

const totalPrice = computed(() =>
  hasQuantity.value
    ? selectedItems.value.reduce(
        (acc, value) => acc + Number(value.price) * value.quantity!,
        0
      )
    : 0
);

const hasQuantity = computed(() => selectedItems.value.some((v) => v.quantity));

const increment = (item: MarketplaceItem) => {
  const foundItem = selectedItems.value.find((i) => i.id === item.id);

  if (foundItem) {
    foundItem.quantity += 1;
  }
};

const decrement = async (item: MarketplaceItem) => {
  const foundItem = selectedItems.value.find((i) => i.id === item.id);

  if (foundItem && foundItem.quantity >= 1) {
    foundItem.quantity -= 1;
    return;
  }

  try {
    await deleteItemModalRef.value?.confirm();
  } catch {
    return;
  }

  selectedItems.value = selectedItems.value.filter((v) => v.id !== item.id);
};
</script>
