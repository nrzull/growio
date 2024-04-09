<template>
  <PageLoader :loading="isLoading" />

  <PageShape>
    <template #heading> Items </template>

    <template #tools>
      <Button size="sm" :icon="plusSvg"> Create </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There are no items' }"
    />
    <Table v-else :table="table"> </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { wait } from "~/composables/wait";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import Table from "~/components/Table.vue";
import Button from "~/components/Button.vue";
import plusSvg from "~/assets/plus.svg";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Notification from "~/components/Notifications/Notification.vue";

const items = ref([]);
const isLoading = computed(() => wait.some([]));

const isEmpty = computed(() => !isLoading.value && !items.value.length);

const columnHelper = createColumnHelper<any>();

const columns = ref([
  columnHelper.accessor("name", {
    cell: (info) => info.getValue(),
    header: () => "Name",
  }),

  columnHelper.accessor("actions" as any, {
    cell: (info) => info.getValue(),
    header: () => "",
  }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return items.value;
  },

  get columns() {
    return columns.value;
  },
});
</script>
