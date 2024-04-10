<template>
  <PageLoader :loading="isLoading" />

  <CreateItemModal
    v-if="createItemModal"
    @close="createItemModal = false"
    @submit="handleCreateItem"
  />

  <PageShape>
    <template #heading> Items </template>

    <template #tools>
      <Button size="sm" :icon="plusSvg" @click="createItemModal = true">
        Create
      </Button>
    </template>

    <div :class="[$style.grid, { [$style.empty]: !categories.length }]">
      <Shape type="secondary" :class="$style.aside" v-if="categories.length">
        <Button
          v-for="category in categories"
          size="md"
          :active="activeCategory?.id === category.id"
          type="neutral"
          :key="category.id"
          @click="activeCategory = category"
        >
          {{ category.name }}
        </Button>
      </Shape>
      <div>
        <Notification
          v-if="isEmpty"
          :model-value="{ type: 'info', text: 'There are no items' }"
        />
        <Table v-else :table="table"> </Table>
      </div>
    </div>
  </PageShape>
</template>

<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { Wait, wait } from "~/composables/wait";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import Table from "~/components/Table.vue";
import Button from "~/components/Button.vue";
import plusSvg from "~/assets/plus.svg";
import Shape from "~/components/Shape.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Notification from "~/components/Notifications/Notification.vue";
import { apiMarketplaceItemCategoriesGetAll } from "~/api/growio/marketplace_item_categories";
import { MarketplaceItemCategory } from "~/api/growio/marketplace_item_categories/types";
import { MarketplaceItem } from "~/api/growio/marketplace_items/types";
import {
  apiMarketplaceItemsGetAll,
  apiMarketplaceItemsCreate,
} from "~/api/growio/marketplace_items";
import { IdParam } from "~/api/types";
import CreateItemModal from "~/components/Inventory/CreateItemModal.vue";

const items = ref<MarketplaceItem[]>([]);
const categories = ref<MarketplaceItemCategory[]>([]);
const activeCategory = ref<MarketplaceItemCategory>();
const createItemModal = ref(false);

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH,
    Wait.MARKETPLACE_ITEM_CREATE,
  ])
);

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

const fetchMarketplaceItemCategories = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH);
    categories.value = await apiMarketplaceItemCategoriesGetAll({
      deleted_at: false,
    });

    activeCategory.value = categories.value[0];
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH);
  }
};

const fetchMarketplaceItems = async (
  params: MarketplaceItemCategory = activeCategory.value
) => {
  try {
    wait.start(Wait.MARKETPLACE_ITEMS_FETCH);

    items.value = await apiMarketplaceItemsGetAll({
      category_item_id: params?.id,
      deleted_at: false,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEMS_FETCH);
  }
};

const handleCreateItem = async (params: {
  name: string;
  category_id: IdParam;
}) => {
  try {
    wait.start(Wait.MARKETPLACE_ITEM_CREATE);

    await apiMarketplaceItemsCreate({
      category_item_id: params.category_id,
      item: params,
    });

    createItemModal.value = false;
    await fetchMarketplaceItems();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CREATE);
  }
};

watch(
  activeCategory,
  (v) => {
    if (v) {
      fetchMarketplaceItems(v);
    }
  },
  { deep: true }
);

fetchMarketplaceItemCategories();
</script>

<style module>
.grid {
  display: grid;
  grid-template-columns: 200px 1fr;
  gap: 24px;
}

.grid.empty {
  grid-template-columns: 1fr;
}

.aside {
  display: flex;
  flex-flow: column;
  gap: 4px;
  padding: 4px;
  height: max-content;
}
</style>
