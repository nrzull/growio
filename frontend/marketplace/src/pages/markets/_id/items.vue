<template>
  <PageLoader :loading="isLoading" />

  <MarketItemModal
    v-if="marketItemModal"
    :model-value="marketItemModal"
    :loading="isLoading"
    @close="marketItemModal = undefined"
    @submit="handleSubmitMarketItem"
  />

  <PromiseModal ref="deleteMarketItemModalRef">
    <template #heading>Delete market item</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <PageShape>
    <template #heading>
      <slot name="tabs"></slot>
    </template>

    <template #tools>
      <Button
        size="sm"
        icon="plus"
        @click="marketItemModal = buildPartialMarketplaceMarketItem()"
      >
        Create
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There is no items' }"
    />
    <Table
      v-else
      :table
      clickable
      @click:row="marketItemModal = $event.original"
    >
      <template #actions="{ ctx }">
        <Icon value="trashCircle" @click.stop="deleteItem(ctx.row.original)" />
      </template>
    </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { computed, PropType, ref } from "vue";
import {
  MarketplaceMarketItem,
  PartialMarketplaceMarketItem,
} from "@growio/shared/api/growio/marketplace_market_items/types";
import { MarketplaceMarket } from "@growio/shared/api/growio/marketplace_markets/types";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import { wait, Wait } from "@growio/shared/composables/wait";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import {
  buildPartialMarketplaceMarketItem,
  isMarketplaceMarketItem,
} from "@growio/shared/api/growio/marketplace_market_items/utils";
import {
  apiMarketplaceMarketItemsCreate,
  apiMarketplaceMarketItemsDelete,
  apiMarketplaceMarketItemsGetAll,
  apiMarketplaceMarketItemsUpdate,
} from "@growio/shared/api/growio/marketplace_market_items";
import MarketItemModal from "~/components/Inventory/MarketItemModal.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import Button from "@growio/shared/components/Button.vue";
import Table from "@growio/shared/components/Table.vue";
import Icon from "@growio/shared/components/Icon.vue";
import Notification from "@growio/shared/components/Notifications/Notification.vue";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  market: {
    type: Object as PropType<MarketplaceMarket>,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const marketItems = ref<MarketplaceMarketItem[]>([]);
const marketItemModal = ref<
  MarketplaceMarketItem | PartialMarketplaceMarketItem
>();
const deleteMarketItemModalRef = ref<InstanceType<typeof PromiseModal>>();

const isLoading = computed(
  () =>
    props.loading ||
    wait.some([
      Wait.MARKETPLACE_MARKET_ITEMS_FETCH,
      Wait.MARKETPLACE_MARKET_ITEM_CREATE,
      Wait.MARKETPLACE_MARKET_ITEM_UPDATE,
      Wait.MARKETPLACE_MARKET_ITEM_DELETE,
    ])
);

const isEmpty = computed(() => !isLoading.value && !marketItems.value.length);

const columnHelper = createColumnHelper<MarketplaceMarketItem>();

const columns = ref([
  columnHelper.accessor("marketplace_item.name", {
    cell: (info) => info.getValue(),
    header: () => "Name",
  }),

  columnHelper.accessor("quantity", {
    cell: (info) => info.getValue(),
    header: () => "Quantity",
  }),

  columnHelper.display({
    id: "actions",

    meta: {
      style: {
        width: "0",
      },
    },
  }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return marketItems.value;
  },

  get columns() {
    return columns.value;
  },
});

const handleSubmitMarketItem = (
  v: PartialMarketplaceMarketItem | MarketplaceMarketItem
) => (isMarketplaceMarketItem(v) ? updateItem(v) : createItem(v));

const updateItem = async (params: MarketplaceMarketItem) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_ITEM_UPDATE);
    await apiMarketplaceMarketItemsUpdate({
      market_id: props.market.id,
      item: params,
    });
    await fetchMarketplaceMarketItems();
    marketItemModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_ITEM_UPDATE);
  }
};

const createItem = async (params: PartialMarketplaceMarketItem) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_ITEM_CREATE);

    await apiMarketplaceMarketItemsCreate({
      market_id: props.market.id,
      item: params,
    });

    await fetchMarketplaceMarketItems();
    marketItemModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_ITEM_CREATE);
  }
};

const deleteItem = async (params: MarketplaceMarketItem) => {
  try {
    await deleteMarketItemModalRef.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_MARKET_ITEM_DELETE);
    await apiMarketplaceMarketItemsDelete({
      market_id: props.market.id,
      item: params,
    });
    await fetchMarketplaceMarketItems();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_ITEM_DELETE);
  }
};

const fetchMarketplaceMarketItems = async () => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_ITEMS_FETCH);
    marketItems.value = await apiMarketplaceMarketItemsGetAll({
      market_id: props.market.id,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_ITEMS_FETCH);
  }
};

fetchMarketplaceMarketItems();
</script>
