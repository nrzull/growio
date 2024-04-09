<template>
  <PageLoader :loading="isLoading" />

  <CreateCategoryModal
    v-if="createCategoryModal"
    @submit="handleSubmitCategory"
    @close="createCategoryModal = false"
  />

  <PageShape>
    <template #heading> Categories </template>

    <template #tools>
      <Button size="sm" :icon="plusSvg" @click="createCategoryModal = true">
        Create
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There are no categories' }"
    />
    <Table v-else :table="table"> </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { wait, Wait } from "~/composables/wait";
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
import CreateCategoryModal from "~/components/Inventory/CreateCategoryModal.vue";
import {
  apiMarketplaceAccountItemCategoriesGetAll,
  apiMarketplaceAccountItemCategoriesCreate,
} from "~/api/growio/marketplace_account_item_categories";
import { MarketplaceAccountItemCategory } from "~/api/growio/marketplace_account_item_categories/types";

const categories = ref<MarketplaceAccountItemCategory[]>([]);
const createCategoryModal = ref(false);

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ACCOUNT_ITEM_CATEGORIES_FETCH,
    Wait.MARKETPLACE_ACCOUNT_ITEM_CATEGORY_CREATE,
  ])
);

const isEmpty = computed(() => !isLoading.value && !categories.value.length);

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
    return categories.value;
  },

  get columns() {
    return columns.value;
  },
});

const handleSubmitCategory = async (params: { name: string }) => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_ITEM_CATEGORY_CREATE);
    await apiMarketplaceAccountItemCategoriesCreate(params);
    createCategoryModal.value = false;
    fetchMarketplaceAccountItemCategories();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_ITEM_CATEGORY_CREATE);
  }
};

const fetchMarketplaceAccountItemCategories = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_ITEM_CATEGORIES_FETCH);
    categories.value = await apiMarketplaceAccountItemCategoriesGetAll();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_ITEM_CATEGORIES_FETCH);
  }
};

fetchMarketplaceAccountItemCategories();
</script>
