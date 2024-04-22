<template>
  <PromiseModal ref="deleteInvitationModalRef">
    <template #heading>Revoke invitation</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <Modal size="lg" :loading="isLoading" @close="$emit('close')">
    <template #heading>Invitations</template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There is no invitations' }"
    />
    <Table v-else :table="table">
      <template #actions="{ ctx }">
        <Icon
          value="trashCircle"
          @click.stop="deleteInvitation(ctx.row.original)"
        />
      </template>
    </Table>
  </Modal>
</template>

<script setup lang="ts">
import Modal from "@growio/shared/components/Modal.vue";
import {
  apiMarketplaceAccountEmailInvitationsGetAll,
  apiMarketplaceAccountEmailInvitationsDelete,
} from "@growio/shared/api/growio/marketplace_account_email_invitations";
import { MarketplaceAccountEmailInvitation } from "@growio/shared/api/growio/marketplace_account_email_invitations/types";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import { computed, ref } from "vue";
import Table from "@growio/shared/components/Table.vue";
import { wait, Wait } from "@growio/shared/composables/wait";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import Icon from "@growio/shared/components/Icon.vue";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import Button from "@growio/shared/components/Button.vue";

defineEmits(["close"]);

defineOptions({ inheritAttrs: false });

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATIONS_FETCH,
    Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_DELETE,
  ])
);

const deleteInvitationModalRef = ref<InstanceType<typeof PromiseModal>>();

const isEmpty = computed(() => !isLoading.value && !invitations.value.length);

const invitations = ref<MarketplaceAccountEmailInvitation[]>([]);

const columnHelper = createColumnHelper<MarketplaceAccountEmailInvitation>();

const columns = ref([
  columnHelper.accessor("email", {
    cell: (info) => info.getValue(),
    header: () => "Email",
  }),

  columnHelper.accessor("role.name", {
    cell: (info) => info.getValue(),
    header: () => "Role",
  }),

  columnHelper.display({ id: "actions", meta: { style: { width: "0" } } }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return invitations.value;
  },

  get columns() {
    return columns.value;
  },
});

const fetchAccountEmailInvitations = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATIONS_FETCH);
    invitations.value = await apiMarketplaceAccountEmailInvitationsGetAll();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATIONS_FETCH);
  }
};

const deleteInvitation = async (params: MarketplaceAccountEmailInvitation) => {
  try {
    await deleteInvitationModalRef.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_DELETE);
    await apiMarketplaceAccountEmailInvitationsDelete(params);
    await fetchAccountEmailInvitations();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_DELETE);
  }
};

fetchAccountEmailInvitations();
</script>
