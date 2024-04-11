<template>
  <PageLoader :loading="isLoading" />

  <CategoryModal
    v-if="categoryModal"
    :model-value="categoryModal"
    :loading="isLoading"
    @close="categoryModal = undefined"
    @submit="handleSubmitCategory"
  />

  <PromiseModal ref="deleteCategoryModal">
    <template #heading>Delete category</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <PageShape>
    <template #heading>
      Categories <template v-if="deletedCategories">(Deleted)</template>
    </template>

    <template #tools>
      <Button size="sm" type="link-neutral" @click="toggleDeletedCategories">
        Toggle deleted categories
      </Button>

      <Button
        :disabled="deletedCategories"
        size="sm"
        icon="plus"
        @click="categoryModal = buildPartialMarketplaceItemCategory()"
      >
        Create
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There are no categories' }"
    />
    <Table
      v-else
      :clickable="!deletedCategories"
      :table="table"
      @click:row="categoryModal = $event.original"
    >
      <template #actions="{ ctx }">
        <Icon
          v-if="!deletedCategories"
          clickable
          value="trashCircle"
          @click.stop="deleteCategory(ctx.row.original)"
        />
      </template>
    </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { wait, Wait } from "~/composables/wait";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import Table from "~/components/Table.vue";
import Button from "~/components/Button.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Notification from "~/components/Notifications/Notification.vue";
import CategoryModal from "~/components/Inventory/CategoryModal.vue";
import {
  apiMarketplaceItemCategoriesGetAll,
  apiMarketplaceItemCategoriesCreate,
  apiMarketplaceItemCategoriesDelete,
  apiMarketplaceItemCategoriesUpdate,
} from "~/api/growio/marketplace_item_categories";
import {
  MarketplaceItemCategory,
  PartialMarketplaceItemCategory,
} from "~/api/growio/marketplace_item_categories/types";
import Icon from "~/components/Icon.vue";
import PromiseModal from "~/components/PromiseModal.vue";
import {
  buildPartialMarketplaceItemCategory,
  isMarketplaceItemCategory,
} from "~/api/growio/marketplace_item_categories/utils";

const categories = ref<MarketplaceItemCategory[]>([]);

const categoryModal = ref<
  MarketplaceItemCategory | PartialMarketplaceItemCategory
>();

const deleteCategoryModal = ref<InstanceType<typeof PromiseModal>>();
const deletedCategories = ref(false);

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH,
    Wait.MARKETPLACE_ITEM_CATEGORY_CREATE,
    Wait.MARKETPLACE_ITEM_CATEGORY_UPDATE,
  ])
);

const isEmpty = computed(() => !isLoading.value && !categories.value.length);

const columnHelper = createColumnHelper<any>();

const columns = ref([
  columnHelper.accessor("name", {
    cell: (info) => info.getValue(),
    header: () => "Name",
  }),

  columnHelper.display({
    id: "actions",
    cell: (info) => info.getValue(),
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
    return categories.value;
  },

  get columns() {
    return columns.value;
  },
});

const handleSubmitCategory = async (
  params: PartialMarketplaceItemCategory | MarketplaceItemCategory
) =>
  isMarketplaceItemCategory(params)
    ? updateCategory(params)
    : createCategory(params);

const createCategory = async (params: PartialMarketplaceItemCategory) => {
  try {
    wait.start(Wait.MARKETPLACE_ITEM_CATEGORY_CREATE);
    await apiMarketplaceItemCategoriesCreate(params);
    categoryModal.value = undefined;
    fetchMarketplaceItemCategories();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CATEGORY_CREATE);
  }
};

const updateCategory = async (params: MarketplaceItemCategory) => {
  try {
    wait.start(Wait.MARKETPLACE_ITEM_CATEGORY_UPDATE);
    await apiMarketplaceItemCategoriesUpdate(params);
    categoryModal.value = undefined;
    fetchMarketplaceItemCategories();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CATEGORY_UPDATE);
  }
};

const fetchMarketplaceItemCategories = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH);
    categories.value = await apiMarketplaceItemCategoriesGetAll({
      deleted_at: deletedCategories.value,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH);
  }
};

const deleteCategory = async (category: MarketplaceItemCategory) => {
  try {
    await deleteCategoryModal.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_ITEM_CATEGORY_DELETE);
    await apiMarketplaceItemCategoriesDelete({ item_category_id: category.id });
    await fetchMarketplaceItemCategories();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CATEGORY_DELETE);
  }
};

const toggleDeletedCategories = () => {
  deletedCategories.value = !deletedCategories.value;
  fetchMarketplaceItemCategories();
};

fetchMarketplaceItemCategories();
</script>

<style module>
.trash {
  height: 32px;
  width: 32px;
  cursor: pointer;
}

.trash:hover * {
  fill: var(--color-primary);
}
</style>
