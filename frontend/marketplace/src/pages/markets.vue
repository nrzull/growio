<template>
  <PageLoader :loading="isLoading" />

  <MarketModal
    v-if="marketModal"
    @close="marketModal = undefined"
    @submit="handleSubmitMarket"
    :loading="isLoading"
    :model-value="marketModal"
  />

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

  <PromiseModal ref="deleteMarketModalRef">
    <template #heading>Delete market</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <PageShape>
    <template #heading>
      <span v-if="activeMarket">
        <Menu
          track-by="title"
          label-path="title"
          :items="[
            { title: 'Edit', action: () => (marketModal = activeMarket) },
            { title: 'Delete', action: () => deleteMarket(activeMarket) },
          ]"
          :use-floating-options="{ placement: 'bottom-start' }"
          @click:item="($event as any).action?.()"
        >
          <div :class="$style.marketTitle">
            {{ activeMarket.name }}
            <Icon value="chevronDown" />
          </div>
        </Menu>
      </span>
      <span v-else>Markets</span>
    </template>

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
      v-if="!markets.length"
      :model-value="{ type: 'info', text: 'There is no markets' }"
    />
    <div v-else :class="$style.grid">
      <Shape type="secondary" :class="$style.aside">
        <Button
          v-for="market in markets"
          :key="market.id"
          size="md"
          type="neutral"
          :active="activeMarket?.id === market.id"
          @click="activeMarket = market"
        >
          {{ market.name }}
        </Button>
      </Shape>

      <div>
        <Notification
          v-if="isEmptyItems"
          :model-value="{ type: 'info', text: 'There is no items' }"
        />
        <Table
          v-else
          :table
          clickable
          @click:row="marketItemModal = $event.original"
        >
          <template #actions="{ ctx }">
            <Icon
              value="trashCircle"
              @click.stop="deleteItem(ctx.row.original)"
            />
          </template>
        </Table>
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
  MarketplaceMarket,
  PartialMarketplaceMarket,
} from "~/api/growio/marketplace_markets/types";
import {
  apiMarketplaceMarketsGetAll,
  apiMarketplaceMarketsCreate,
  apiMarketplaceMarketsUpdate,
  apiMarketplaceMarketsDelete,
} from "~/api/growio/marketplace_markets";
import {
  apiMarketplaceMarketItemsCreate,
  apiMarketplaceMarketItemsDelete,
  apiMarketplaceMarketItemsGetAll,
  apiMarketplaceMarketItemsUpdate,
} from "~/api/growio/marketplace_market_items";
import {
  MarketplaceMarketItem,
  PartialMarketplaceMarketItem,
} from "~/api/growio/marketplace_market_items/types";
import MarketModal from "~/components/Inventory/MarketModal.vue";
import MarketItemModal from "~/components/Inventory/MarketItemModal.vue";
import {
  buildPartialMarketplaceMarket,
  isMarketplaceMarket,
} from "~/api/growio/marketplace_markets/utils";
import {
  buildPartialMarketplaceMarketItem,
  isMarketplaceMarketItem,
} from "~/api/growio/marketplace_market_items/utils";
import PromiseModal from "~/components/PromiseModal.vue";
import Icon from "~/components/Icon.vue";

const activeMarket = ref<MarketplaceMarket>();
const markets = ref<MarketplaceMarket[]>([]);
const marketItems = ref<MarketplaceMarketItem[]>([]);

const marketModal = ref<MarketplaceMarket | PartialMarketplaceMarket>();

const marketItemModal = ref<
  MarketplaceMarketItem | PartialMarketplaceMarketItem
>();

const deleteMarketItemModalRef = ref<InstanceType<typeof PromiseModal>>();
const deleteMarketModalRef = ref<InstanceType<typeof PromiseModal>>();

watch(
  activeMarket,
  (v) => {
    if (v) {
      fetchMarketplaceMarketItems(v);
    }
  },
  { deep: true }
);

watch(
  markets,
  (v) => {
    if (v.length && !activeMarket.value) {
      activeMarket.value = v[0];
    }
  },
  { deep: true }
);

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_MARKETS_FETCH,
    Wait.MARKETPLACE_MARKET_CREATE,
    Wait.MARKETPLACE_MARKET_ITEMS_FETCH,
    Wait.MARKETPLACE_MARKET_ITEM_CREATE,
    Wait.MARKETPLACE_MARKET_ITEM_UPDATE,
    Wait.MARKETPLACE_MARKET_ITEM_DELETE,
  ])
);

const isEmptyItems = computed(
  () => !isLoading.value && !marketItems.value.length
);

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

const createMenuItems = computed(() => {
  const base = [{ title: "Market", action: handleCreateMarket }];

  if (markets.value.length) {
    base.push({ title: "Item", action: handleCreateItem });
  }

  return base;
});

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return marketItems.value;
  },

  get columns() {
    return columns.value;
  },
});

const handleSubmitMarket = (v: PartialMarketplaceMarket | MarketplaceMarket) =>
  isMarketplaceMarket(v) ? updateMarket(v) : createMarket(v);

const handleSubmitMarketItem = (
  v: PartialMarketplaceMarketItem | MarketplaceMarketItem
) => (isMarketplaceMarketItem(v) ? updateItem(v) : createItem(v));

const handleCreateItem = () => {
  marketItemModal.value = buildPartialMarketplaceMarketItem();
};

const updateItem = async (params: MarketplaceMarketItem) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_ITEM_UPDATE);
    await apiMarketplaceMarketItemsUpdate({
      market_id: activeMarket.value.id,
      item: params,
    });
    await fetchMarketplaceMarketItems(activeMarket.value);
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
      market_id: activeMarket.value.id,
      item: params,
    });

    await fetchMarketplaceMarketItems(activeMarket.value);
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
      market_id: activeMarket.value.id,
      item: params,
    });
    await fetchMarketplaceMarketItems(activeMarket.value);
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_ITEM_DELETE);
  }
};

const handleCreateMarket = () => {
  marketModal.value = buildPartialMarketplaceMarket();
};

const createMarket = async (params: PartialMarketplaceMarket) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_CREATE);
    await apiMarketplaceMarketsCreate(params);
    await fetchMarkets();
    marketModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_CREATE);
  }
};

const updateMarket = async (params: MarketplaceMarket) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_UPDATE);
    await apiMarketplaceMarketsUpdate(params);
    await fetchMarkets();
    marketModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_UPDATE);
  }
};

const deleteMarket = async (params: MarketplaceMarket) => {
  try {
    await deleteMarketModalRef.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_MARKET_DELETE);
    const deletedMarket = await apiMarketplaceMarketsDelete(params);

    await fetchMarkets();

    if (activeMarket.value?.id === deletedMarket.id) {
      activeMarket.value = markets.value[0];
    }
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_DELETE);
  }
};

const fetchMarkets = async () => {
  try {
    wait.start(Wait.MARKETPLACE_MARKETS_FETCH);
    markets.value = await apiMarketplaceMarketsGetAll();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKETS_FETCH);
  }
};

const fetchMarketplaceMarketItems = async (params: MarketplaceMarket) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_ITEMS_FETCH);
    marketItems.value = await apiMarketplaceMarketItemsGetAll({
      market_id: params.id,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_ITEMS_FETCH);
  }
};

fetchMarkets();
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

.marketTitle {
  display: inline-flex;
  align-items: center;
  user-select: none;
}

.marketTitle svg {
  width: 12px;
  height: 12px;
}
</style>
