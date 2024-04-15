<template>
  <PageLoader :loading="isLoading" />

  <WarehouseModal
    v-if="warehouseModal"
    @close="warehouseModal = undefined"
    @submit="createWarehouse"
    :loading="isLoading"
    :model-value="warehouseModal"
  />

  <WarehouseItemModal
    v-if="warehouseItemModal"
    :model-value="warehouseItemModal"
    :loading="isLoading"
    @close="warehouseItemModal = undefined"
    @submit="createItem"
  />

  <PageShape>
    <template #heading> Warehouses </template>

    <template #tools>
      <Menu
        track-by="title"
        label-path="title"
        :items="createMenuItems"
        @click:item="($event as any).action?.()"
      >
        <Button size="sm" icon="plus"> Create </Button>
      </Menu>
    </template>

    <Notification
      v-if="!warehouses.length"
      :model-value="{ type: 'info', text: 'There is no warehouses' }"
    />
    <div v-else :class="$style.grid">
      <Shape type="secondary" :class="$style.aside">
        <Button
          v-for="warehouse in warehouses"
          :key="warehouse.id"
          size="md"
          type="neutral"
          :active="activeWarehouse?.id === warehouse.id"
          @click="activeWarehouse = warehouse"
        >
          {{ warehouse.name }}
        </Button>
      </Shape>

      <div>
        <Notification
          v-if="isEmptyItems"
          :model-value="{ type: 'info', text: 'There is no items' }"
        />
        <Table v-else :table />
      </div>
    </div>
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed, watch } from "vue";
import { wait, Wait } from "~/composables/wait";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import Button from "~/components/Button.vue";
import Shape from "~/components/Shape.vue";
import Table from "~/components/Table.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Menu from "~/components/Menu.vue";
import Notification from "~/components/Notifications/Notification.vue";
import {
  MarketplaceWarehouse,
  PartialMarketplaceWarehouse,
} from "~/api/growio/marketplace_warehouses/types";
import {
  apiMarketplaceWarehousesGetAll,
  apiMarketplaceWarehousesCreate,
} from "~/api/growio/marketplace_warehouses";
import {
  apiMarketplaceWarehouseItemsCreate,
  apiMarketplaceWarehouseItemsGetAll,
} from "~/api/growio/marketplace_warehouse_items";
import {
  MarketplaceWarehouseItem,
  PartialMarketplaceWarehouseItem,
} from "~/api/growio/marketplace_warehouse_items/types";
import WarehouseModal from "~/components/Inventory/WarehouseModal.vue";
import WarehouseItemModal from "~/components/Inventory/WarehouseItemModal.vue";
import { buildPartialMarketplaceWarehouse } from "~/api/growio/marketplace_warehouses/utils";
import { buildPartialMarketplaceWarehouseItem } from "~/api/growio/marketplace_warehouse_items/utils";

const activeWarehouse = ref();
const warehouses = ref<MarketplaceWarehouse[]>([]);
const warehouseItems = ref<MarketplaceWarehouseItem[]>([]);

watch(
  activeWarehouse,
  (v) => {
    if (v) {
      fetchMarketplaceWarehouseItems(v);
    }
  },
  { deep: true }
);

watch(
  warehouses,
  (v) => {
    if (v.length && !activeWarehouse.value) {
      activeWarehouse.value = v[0];
    }
  },
  { deep: true }
);

const warehouseModal = ref<
  MarketplaceWarehouse | PartialMarketplaceWarehouse
>();

const warehouseItemModal = ref<
  MarketplaceWarehouseItem | PartialMarketplaceWarehouseItem
>();

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_WAREHOUSES_FETCH,
    Wait.MARKETPLACE_WAREHOUSE_CREATE,
    Wait.MARKETPLACE_WAREHOUSE_ITEMS_FETCH,
  ])
);

const isEmptyItems = computed(
  () => !isLoading.value && !warehouseItems.value.length
);

const columnHelper = createColumnHelper<MarketplaceWarehouseItem>();

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

const createMenuItems = computed(() => {
  const base = [{ title: "Warehouse", action: handleCreateWarehouse }];

  if (warehouses.value.length) {
    base.push({ title: "Item", action: handleCreateItem });
  }

  return base;
});

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return warehouseItems.value;
  },

  get columns() {
    return columns.value;
  },
});

const handleCreateItem = () => {
  warehouseItemModal.value = buildPartialMarketplaceWarehouseItem();
};

const createItem = async (params: PartialMarketplaceWarehouseItem) => {
  try {
    await apiMarketplaceWarehouseItemsCreate({
      warehouse_id: activeWarehouse.value.id,
      item: params,
    });

    await fetchMarketplaceWarehouseItems(activeWarehouse.value);
    warehouseItemModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
  }
};

const handleCreateWarehouse = () => {
  warehouseModal.value = buildPartialMarketplaceWarehouse();
};

const createWarehouse = async (params: PartialMarketplaceWarehouse) => {
  try {
    wait.start(Wait.MARKETPLACE_WAREHOUSE_CREATE);
    await apiMarketplaceWarehousesCreate(params);
    await fetchWarehouses();
    warehouseModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_WAREHOUSE_CREATE);
  }
};

const fetchWarehouses = async () => {
  try {
    wait.start(Wait.MARKETPLACE_WAREHOUSES_FETCH);
    warehouses.value = await apiMarketplaceWarehousesGetAll();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_WAREHOUSES_FETCH);
  }
};

const fetchMarketplaceWarehouseItems = async (params: MarketplaceWarehouse) => {
  try {
    wait.start(Wait.MARKETPLACE_WAREHOUSE_ITEMS_FETCH);
    warehouseItems.value = await apiMarketplaceWarehouseItemsGetAll({
      warehouse_id: params.id,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_WAREHOUSE_ITEMS_FETCH);
  }
};

fetchWarehouses();
</script>

<style module>
.grid {
  display: grid;
  grid-template-columns: 200px 1fr;
  gap: 24px;
}

.aside {
  display: flex;
  flex-flow: column;
  gap: 4px;
  padding: 4px;
  height: max-content;
}
</style>
