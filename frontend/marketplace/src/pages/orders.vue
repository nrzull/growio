<template>
  <PageLoader :loading="isLoading" />

  <PageShape>
    <template #heading>Orders</template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There is no orders' }"
    />
    <Table v-else :table></Table>
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import { Wait, wait } from "@growio/shared/composables/wait";
import Table from "@growio/shared/components/Table.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import { MarketplaceMarketOrder } from "@growio/shared/api/growio/marketplace_market_orders/types";
import { apiMarketplaceGetAllOrders } from "@growio/shared/api/growio/marketplaces";

const orders = ref<MarketplaceMarketOrder[]>([]);

const columnHelper = createColumnHelper<MarketplaceMarketOrder>();

const columns = ref([
  columnHelper.accessor("id", {
    cell: (info) => info.getValue(),
    header: () => "Order ID",
  }),

  columnHelper.accessor("status", {
    cell: (info) => info.getValue(),
    header: () => "Status",
  }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return orders.value;
  },

  get columns() {
    return columns.value;
  },
});

const isLoading = computed(() =>
  wait.some([Wait.MARKETPLACE_MARKET_ORDERS_FETCH])
);
const isEmpty = computed(() => !isLoading.value && !orders.value.length);

const fetchOrders = async () => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_ORDERS_FETCH);
    orders.value = await apiMarketplaceGetAllOrders();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_ORDERS_FETCH);
  }
};

fetchOrders();
</script>
