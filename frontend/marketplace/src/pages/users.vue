<template>
  <PageLoader :loading="isLoading" />

  <InviteUserModal v-if="inviteUserModal" @close="inviteUserModal = false" />

  <InvitationsModal v-if="invitationsModal" @close="invitationsModal = false" />

  <PageShape>
    <template #heading>Users</template>

    <template #tools>
      <Button size="sm" type="neutral" @click="invitationsModal = true">
        Invitations
      </Button>
      <Button size="sm" :icon="plusSvg" @click="inviteUserModal = true">
        Invite
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There are no users' }"
    />
    <Table v-else :table="table" />
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
import { wait, Wait } from "~/composables/wait";
import { apiMarketplaceAccountsGetAll } from "~/api/growio/marketplace_accounts";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import Button from "~/components/Button.vue";
import plusSvg from "~/assets/plus.svg";
import InviteUserModal from "~/components/Users/InviteUserModal.vue";
import InvitationsModal from "~/components/Users/InvitationsModal.vue";
import Notification from "~/components/Notifications/Notification.vue";

const inviteUserModal = ref(false);
const invitationsModal = ref(false);

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

const isLoading = computed(() => wait.some([Wait.MARKETPLACE_ACCOUNTS_FETCH]));

const isEmpty = computed(
  () => !isLoading.value && !marketplaceAccounts.value.length
);

const fetchMarketplaceAccounts = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNTS_FETCH);
    marketplaceAccounts.value = await apiMarketplaceAccountsGetAll();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNTS_FETCH);
  }
};

fetchMarketplaceAccounts();
</script>
