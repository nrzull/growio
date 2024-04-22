<template>
  <PageLoader :loading="isLoading" />

  <MarketModal
    v-if="marketModal"
    @close="marketModal = undefined"
    @submit="createMarket"
    :loading="isLoading"
    :model-value="marketModal"
  />

  <PromiseModal ref="deleteMarketModalRef">
    <template #heading>Delete market</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <PageShape>
    <template #heading> Markets </template>

    <template #tools>
      <Button
        size="sm"
        icon="plus"
        @click="marketModal = buildPartialMarketplaceMarket()"
      >
        Create
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There is no markets' }"
    />
    <Table
      v-else
      :table
      clickable
      @click:row="$router.push(`/markets/${$event.original.id}`)"
    >
      <template #actions="{ ctx }">
        <Icon
          value="trashCircle"
          @click.stop="deleteMarket(ctx.row.original)"
        />
      </template>
    </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { wait, Wait } from "@growio/shared/composables/wait";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import Button from "@growio/shared/components/Button.vue";
import Table from "@growio/shared/components/Table.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import {
  MarketplaceMarket,
  PartialMarketplaceMarket,
} from "@growio/shared/api/growio/marketplace_markets/types";
import {
  apiMarketplaceMarketsGetAll,
  apiMarketplaceMarketsCreate,
  apiMarketplaceMarketsDelete,
} from "@growio/shared/api/growio/marketplace_markets";
import MarketModal from "~/components/Inventory/MarketModal.vue";
import { buildPartialMarketplaceMarket } from "@growio/shared/api/growio/marketplace_markets/utils";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import Icon from "@growio/shared/components/Icon.vue";

const markets = ref<MarketplaceMarket[]>([]);

const marketModal = ref<PartialMarketplaceMarket>();

const deleteMarketModalRef = ref<InstanceType<typeof PromiseModal>>();

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_MARKETS_FETCH,
    Wait.MARKETPLACE_MARKET_CREATE,
    Wait.MARKETPLACE_MARKET_DELETE,
  ])
);

const isEmpty = computed(() => !isLoading.value && !markets.value.length);

const columnHelper = createColumnHelper<MarketplaceMarket>();

const columns = ref([
  columnHelper.accessor("address", {
    cell: (info) => info.getValue(),
    header: () => "Address",
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
    return markets.value;
  },

  get columns() {
    return columns.value;
  },
});

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

const deleteMarket = async (params: MarketplaceMarket) => {
  try {
    await deleteMarketModalRef.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_MARKET_DELETE);
    await apiMarketplaceMarketsDelete(params);
    await fetchMarkets();
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

fetchMarkets();
</script>
