<template>
  <Modal size="lg" @close="$emit('close')">
    <template #heading>Invitations</template>

    <Table :table="table" />
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
import { ref } from "vue";
import Table from "~/components/Table.vue";

defineEmits(["close"]);

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

apiMarketplaceAccountEmailInvitationsGetAll().then(
  (r) => (invitations.value = r)
);
</script>
