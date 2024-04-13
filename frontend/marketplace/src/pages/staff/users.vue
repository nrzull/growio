<template>
  <PageLoader :loading="isLoading" />

  <InvitationModal
    v-if="invitationModal"
    :loading="isLoading"
    @close="invitationModal = false"
    @submit="createInvitation"
  />

  <UserModal
    v-if="userModal"
    :loading="isLoading"
    :model-value="userModal"
    @close="userModal = undefined"
    @submit="updateUser"
  />

  <InvitationsModal v-if="invitationsModal" @close="invitationsModal = false" />

  <PageShape>
    <template #heading>Users</template>

    <template #tools>
      <Button size="sm" type="link-neutral" @click="invitationsModal = true">
        Invitations
      </Button>
      <Button size="sm" icon="plus" @click="invitationModal = true">
        Invite
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There are no users' }"
    />
    <Table
      v-else
      clickable
      :table="table"
      @click:row="userModal = $event.original"
    />
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
import { apiMarketplaceAccountEmailInvitationsCreate } from "~/api/growio/marketplace_account_email_invitations";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import Button from "~/components/Button.vue";
import InvitationModal from "~/components/Staff/InvitationModal.vue";
import InvitationsModal from "~/components/Staff/InvitationsModal.vue";
import UserModal from "~/components/Staff/UserModal.vue";
import Notification from "~/components/Notifications/Notification.vue";

const invitationModal = ref(false);
const invitationsModal = ref(false);
const userModal = ref<MarketplaceAccount>();
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

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ACCOUNTS_FETCH,
    Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_CREATE,
    Wait.MARKETPLACE_ACCOUNT_UPDATE,
  ])
);

const isEmpty = computed(
  () => !isLoading.value && !marketplaceAccounts.value.length
);

const createInvitation = async (params: { email: string; role_id: number }) => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_CREATE);
    await apiMarketplaceAccountEmailInvitationsCreate(params);
    invitationModal.value = false;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_CREATE);
  }
};

const updateUser = async (params: MarketplaceAccount) => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_UPDATE);
    console.log(params);
    userModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_UPDATE);
  }
};

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
