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
    :readonly="userModal.id === marketplaceAccount.id"
    @close="userModal = undefined"
    @submit="updateUser"
  />

  <PromiseModal ref="deleteUserModalRef">
    <template #heading>Block user</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <InvitationsModal v-if="invitationsModal" @close="invitationsModal = false" />

  <PageShape>
    <template #heading> Users <Tag v-if="blockedUsers">Blocked</Tag> </template>

    <template #tools>
      <Button size="sm" type="link-neutral" @click="toggleBlockedUsers">
        Toggle blocked users
      </Button>
      <Button size="sm" type="link-neutral" @click="invitationsModal = true">
        Invitations
      </Button>
      <Button size="sm" icon="plus" @click="invitationModal = true">
        Invite
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There is no users' }"
    />
    <Table
      v-else
      :clickable="!blockedUsers"
      :table="table"
      @click:row="userModal = $event.original"
    >
      <template #actions="{ ctx }">
        <Icon
          v-if="!blockedUsers && ctx.row.original.id !== marketplaceAccount.id"
          value="trashCircle"
          @click.stop="blockUser(ctx.row.original)"
        />
      </template>
    </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Table from "@growio/shared/components/Table.vue";
import { MarketplaceAccount } from "@growio/shared/api/growio/marketplace_accounts/types";
import { wait, Wait } from "@growio/shared/composables/wait";
import {
  apiMarketplaceAccountsGetAll,
  apiMarketplaceAccountsUpdate,
  apiMarketplaceAccountsBlock,
} from "@growio/shared/api/growio/marketplace_accounts";
import { apiMarketplaceAccountEmailInvitationsCreate } from "@growio/shared/api/growio/marketplace_account_email_invitations";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import Button from "@growio/shared/components/Button.vue";
import InvitationModal from "~/components/Staff/InvitationModal.vue";
import InvitationsModal from "~/components/Staff/InvitationsModal.vue";
import UserModal from "~/components/Staff/UserModal.vue";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import Icon from "@growio/shared/components/Icon.vue";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import { marketplaceAccount } from "~/composables/marketplace-accounts";
import Tag from "@growio/shared/components/Tag.vue";

const invitationModal = ref(false);
const invitationsModal = ref(false);
const userModal = ref<MarketplaceAccount>();
const deleteUserModalRef = ref<InstanceType<typeof PromiseModal>>();
const marketplaceAccounts = ref<MarketplaceAccount[]>([]);
const blockedUsers = ref(false);

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
    Wait.MARKETPLACE_ACCOUNT_BLOCK,
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

    await apiMarketplaceAccountsUpdate({
      id: params.id,
      role_id: params.role.id,
    });

    fetchMarketplaceAccounts();
    userModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_UPDATE);
  }
};

const toggleBlockedUsers = () => {
  blockedUsers.value = !blockedUsers.value;
  fetchMarketplaceAccounts();
};

const blockUser = async (params: MarketplaceAccount) => {
  try {
    await deleteUserModalRef.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_BLOCK);
    await apiMarketplaceAccountsBlock(params);
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_BLOCK);
  }
};

const fetchMarketplaceAccounts = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNTS_FETCH);
    marketplaceAccounts.value = await apiMarketplaceAccountsGetAll({
      blocked_at: blockedUsers.value,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNTS_FETCH);
  }
};

fetchMarketplaceAccounts();
</script>
