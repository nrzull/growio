<template>
  <PageLoader v-if="isLoading" />

  <PageShape>
    <template #heading>Users</template>
    <template #tools>
      <Button size="sm" :icon="plusSvg">Invite</Button>
    </template>

    <Table :table="table" />
  </PageShape>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Table from "~/components/Table.vue";
import { MarketplaceAccount } from "~/api/growio/marketplace_accounts/types";
import { wait } from "~/composables/wait";
import { WAIT_MARKETPLACE_ACCOUNTS_FETCH } from "~/constants";
import { apiMarketplaceAccountsGetAll } from "~/api/growio/marketplace_accounts";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import Button from "~/components/Button.vue";
import plusSvg from "~/assets/plus.svg";

const marketplaceAccounts = ref<MarketplaceAccount[]>([]);

const columnHelper = createColumnHelper<MarketplaceAccount>();

const columns = ref([
  columnHelper.accessor("account.email", {
    cell: (info) => info.getValue(),
    header: () => "Email",
  }),

  columnHelper.accessor("role.name", {
    cell: (info) => info.getValue(),
    header: () => "Role",
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

const isLoading = computed(() => wait.some([WAIT_MARKETPLACE_ACCOUNTS_FETCH]));

const fetchMarketplaceAccounts = async () => {
  try {
    wait.start(WAIT_MARKETPLACE_ACCOUNTS_FETCH);
    marketplaceAccounts.value = await apiMarketplaceAccountsGetAll();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(WAIT_MARKETPLACE_ACCOUNTS_FETCH);
  }
};

fetchMarketplaceAccounts();
</script>
