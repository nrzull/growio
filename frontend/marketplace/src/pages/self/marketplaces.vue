<template>
  <PageLoader :loading="isLoading" />

  <MarketplaceModal
    v-if="marketplaceModal"
    :loading="isLoading"
    @close="marketplaceModal = false"
    @submit="createMarketplace"
  />

  <PageShape>
    <template #heading> Marketplaces </template>

    <template #tools>
      <Button size="sm" icon="plus" @click="marketplaceModal = true">
        Create
      </Button>
    </template>

    <Table :table="table">
      <template #actions="{ ctx }">
        <Icon
          clickable
          value="arrowRightFromBracket"
          @click.stop="switchActiveMarketplaceAccount(ctx.row.original)"
        />
      </template>
    </Table>
  </PageShape>
</template>

<script setup lang="ts">
import PageLoader from "@growio/shared/components/PageLoader.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import { computed, ref } from "vue";
import { wait, Wait } from "@growio/shared/composables/wait";
import Button from "@growio/shared/components/Button.vue";
import {
  marketplaceAccounts,
  fetchMarketplaceAccounts,
} from "~/composables/marketplace-accounts";
import { MarketplaceAccount } from "@growio/shared/api/growio/marketplace_accounts/types";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Table from "@growio/shared/components/Table.vue";
import MarketplaceModal from "~/components/Self/MarketplaceModal.vue";
import { apiMarketplacesCreate } from "@growio/shared/api/growio/marketplaces";
import Icon from "@growio/shared/components/Icon.vue";
import { apiMarketplaceAccountsUpdateSelfActive } from "@growio/shared/api/growio/marketplace_accounts";

const marketplaceModal = ref(false);

const isLoading = computed(() =>
  wait.some([Wait.MARKETPLACE_CREATE, Wait.MARKETPLACE_ACCOUNT_SWITCH])
);

const columnHelper = createColumnHelper<MarketplaceAccount>();

const columns = ref([
  columnHelper.accessor("marketplace.name", {
    cell: (info) => info.getValue(),
    header: () => "Marketplace",
  }),

  columnHelper.accessor("role.name", {
    cell: (info) => info.getValue(),
    header: () => "Role",
  }),

  columnHelper.display({
    id: "actions",
    cell: (info) => info.getValue(),
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
    return marketplaceAccounts.value;
  },

  get columns() {
    return columns.value;
  },
});

const createMarketplace = async (params: { name: string }) => {
  try {
    wait.start(Wait.MARKETPLACE_CREATE);
    await apiMarketplacesCreate(params);
    await fetchMarketplaceAccounts();
    marketplaceModal.value = false;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_CREATE);
  }
};

const switchActiveMarketplaceAccount = async (params: MarketplaceAccount) => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_SWITCH);
    await apiMarketplaceAccountsUpdateSelfActive(params);
    location.reload();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_SWITCH);
  }
};

fetchMarketplaceAccounts();
</script>
