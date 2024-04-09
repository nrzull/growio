<template>
  <PageLoader :loading="isLoading" />

  <Modal size="lg" @close="$emit('close')">
    <template #heading>Invitations</template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There is no invitations' }"
    />
    <Table v-else :table="table" />
  </Modal>
</template>

<script setup lang="ts">
import Modal from "~/components/Modal.vue";
import { apiMarketplaceAccountEmailInvitationsGetAll } from "~/api/growio/marketplace_account_email_invitations";
import { MarketplaceAccountEmailInvitation } from "~/api/growio/marketplace_account_email_invitations/types";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import { computed, ref } from "vue";
import Table from "~/components/Table.vue";
import { wait, Wait } from "~/composables/wait";
import PageLoader from "~/components/PageLoader.vue";
import Notification from "~/components/Notifications/Notification.vue";

defineEmits(["close"]);

defineOptions({ inheritAttrs: false });

const isLoading = computed(() =>
  wait.some([Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATIONS_FETCH])
);

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

fetchAccountEmailInvitations();
</script>
