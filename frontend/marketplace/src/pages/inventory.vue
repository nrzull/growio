<template>
  <PageLoader :loading="isLoading" />

  <ItemModal
    v-if="itemModal"
    :model-value="itemModal"
    :loading="isLoading"
    @close="itemModal = undefined"
    @submit="handleSubmitItem"
  />

  <PromiseModal ref="deleteItemModal">
    <template #heading>Delete item</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

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
    <template #heading>Inventory</template>

    <template #tools>
      <Button size="sm" type="link-neutral" @click="toggleDeletedItemTree">
        Toggle deleted items
      </Button>

      <Button
        :disabled="deletedTree"
        size="sm"
        icon="plus"
        @click="categoryModal = buildPartialMarketplaceItemCategory()"
      >
        Create
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There is no items' }"
    />
    <Table
      v-else
      :columns="columns"
      :table="table"
      :clickable="!deletedTree"
      expander-path="expander"
      children-path="children"
      @click:row="handleClickRow($event.original)"
    >
      <template #name="{ ctx }">
        <Icon
          :value="ctx.row.original.category_id ? 'adProduct' : 'folderFilled'"
        />
        <span>{{ ctx.row.original.name }}</span>
      </template>

      <template #actions="{ ctx }" v-if="!deletedTree">
        <Menu
          track-by="id"
          label-path="title"
          :items="[
            { id: 'category', title: 'Category' },
            { id: 'item', title: 'Item' },
          ]"
          @click:item="handleAddRow($event as ItemComplex, ctx.row.original)"
        >
          <Button
            v-if="isMarketplaceTreeItemCategory(ctx.row.original)"
            size="sm"
            type="link-neutral"
            icon="plus"
          >
            Add
          </Button>
        </Menu>

        <Button
          size="md"
          :disabled="!!ctx.row.original.children?.length"
          icon="trashCircle"
          type="link-neutral"
          @click.stop="handleDeleteRow(ctx.row.original)"
        >
        </Button>
      </template>
    </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import Button from "@growio/shared/components/Button.vue";
import { apiMarketplaceItemsTree } from "@growio/shared/api/growio/marketplace_items_tree";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import {
  MarketplaceItemsTree,
  MarketplaceTreeItemCategory,
} from "@growio/shared/api/growio/marketplace_items_tree/types";
import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "@growio/shared/api/growio/marketplace_items/types";
import Table from "@growio/shared/components/Table.vue";
import Icon from "@growio/shared/components/Icon.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import Menu from "@growio/shared/components/Menu.vue";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import { Wait, wait } from "@growio/shared/composables/wait";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import {
  apiMarketplaceItemCategoriesCreate,
  apiMarketplaceItemCategoriesDelete,
  apiMarketplaceItemCategoriesUpdate,
} from "@growio/shared/api/growio/marketplace_item_categories";
import {
  MarketplaceItemCategory,
  PartialMarketplaceItemCategory,
} from "@growio/shared/api/growio/marketplace_item_categories/types";
import { isMarketplaceItemCategory } from "@growio/shared/api/growio/marketplace_item_categories/utils";
import { isMarketplaceTreeItemCategory } from "@growio/shared/api/growio/marketplace_items_tree/utils";
import CategoryModal from "~/components/Inventory/CategoryModal.vue";
import { buildPartialMarketplaceItemCategory } from "@growio/shared/api/growio/marketplace_item_categories/utils";
import { ItemComplex } from "@growio/shared/components/Menu/types";
import {
  buildPartialMarketplaceItem,
  isMarketplaceItem,
} from "@growio/shared/api/growio/marketplace_items/utils";
import {
  MarketplaceItemAsset,
  PartialMarketplaceItemAsset,
} from "@growio/shared/api/growio/marketplace_item_assets/types";
import {
  apiMarketplaceItemsCreate,
  apiMarketplaceItemsDelete,
  apiMarketplaceItemsUpdate,
} from "@growio/shared/api/growio/marketplace_items";
import {
  apiMarketplaceItemAssetsCreate,
  apiMarketplaceItemAssetsDelete,
} from "@growio/shared/api/growio/marketplace_item_assets";
import ItemModal from "~/components/Inventory/ItemModal.vue";

const tree = ref<MarketplaceItemsTree>([]);
const deletedTree = ref(false);
const deleteCategoryModal = ref<InstanceType<typeof PromiseModal>>();

const categoryModal = ref<
  MarketplaceItemCategory | PartialMarketplaceItemCategory
>();

const itemModal = ref<PartialMarketplaceItem | MarketplaceItem>();
const deleteItemModal = ref<InstanceType<typeof PromiseModal>>();

const columnHelper = createColumnHelper<
  MarketplaceTreeItemCategory | MarketplaceItem
>();

const columns = ref([
  columnHelper.accessor("name", {
    cell: (info) => info.getValue(),
    header: () => "Name",
  }),

  columnHelper.display({
    id: "actions",
    cell: (info) => info.getValue(),
    meta: {
      innerBodyStyle: {
        width: "100%",
        "justify-content": "flex-end",
      },
    },
  }),

  columnHelper.display({
    id: "expander",
    cell: (info) => info.getValue(),
    meta: {
      style: {
        width: "0",
      },
    },
  }),
]);

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH,
    Wait.MARKETPLACE_ITEM_CATEGORY_CREATE,
    Wait.MARKETPLACE_ITEM_CATEGORY_UPDATE,
    Wait.MARKETPLACE_ITEMS_TREE_FETCH,
    Wait.MARKETPLACE_ITEM_CREATE,
    Wait.MARKETPLACE_ITEM_UPDATE,
    Wait.MARKETPLACE_ITEM_DELETE,
    Wait.MARKETPLACE_ITEM_ASSET_CREATE,
    Wait.MARKETPLACE_ITEM_ASSET_DELETE,
  ])
);

const isEmpty = computed(() => !isLoading.value && !tree.value.length);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return tree.value;
  },

  get columns() {
    return columns.value;
  },
});

const handleAddRow = (
  { id }: ItemComplex,
  parent: MarketplaceTreeItemCategory
) =>
  id === "category"
    ? (categoryModal.value = buildPartialMarketplaceItemCategory({
        parent_id: parent.id,
      }))
    : (itemModal.value = buildPartialMarketplaceItem({
        category_id: parent.id!,
      }));

const handleClickRow = (v) =>
  isMarketplaceTreeItemCategory(v)
    ? (categoryModal.value = v)
    : (itemModal.value = v);

const handleDeleteRow = (v) =>
  isMarketplaceTreeItemCategory(v) ? deleteCategory(v) : deleteItem(v);

const fetchItemTree = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ITEMS_TREE_FETCH);
    tree.value = await apiMarketplaceItemsTree({
      deleted_at: deletedTree.value,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEMS_TREE_FETCH);
  }
};

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
    fetchItemTree();
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
    fetchItemTree();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CATEGORY_UPDATE);
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
    await fetchItemTree();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CATEGORY_DELETE);
  }
};

const toggleDeletedItemTree = () => {
  deletedTree.value = !deletedTree.value;
  fetchItemTree();
};

const handleSubmitItem = async (params: {
  item: MarketplaceItem | PartialMarketplaceItem;
  assetsCreate: PartialMarketplaceItemAsset[];
  assetsDelete: MarketplaceItemAsset[];
}) =>
  isMarketplaceItem(params.item)
    ? updateItem({
        item: params.item,
        assetsCreate: params.assetsCreate,
        assetsDelete: params.assetsDelete,
      })
    : createItem({
        item: params.item,
        assetsCreate: params.assetsCreate,
      });

const createItem = async (params: {
  item: PartialMarketplaceItem;
  assetsCreate: PartialMarketplaceItemAsset[];
}) => {
  try {
    wait.start(Wait.MARKETPLACE_ITEM_CREATE);

    const createdItem = await apiMarketplaceItemsCreate(params.item);
    await createAssets({ item: createdItem, assets: params.assetsCreate });

    itemModal.value = undefined;
    await fetchItemTree();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_CREATE);
  }
};

const createAssets = async (params: {
  item: MarketplaceItem;
  assets: PartialMarketplaceItemAsset[];
}) => {
  try {
    const { item, assets } = params;

    wait.start(Wait.MARKETPLACE_ITEM_ASSET_CREATE);

    const results = await Promise.allSettled(
      assets.map((v) =>
        apiMarketplaceItemAssetsCreate({
          item_id: item.id,
          category_id: item.category_id,
          asset: v,
        })
      )
    );

    results.forEach((r) => {
      if (r.status === "rejected") {
        console.error(r.reason);
      }
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_ASSET_CREATE);
  }
};

const deleteAssets = async (params: {
  item: MarketplaceItem;
  assets: MarketplaceItemAsset[];
}) => {
  try {
    const { item, assets } = params;

    const results = await Promise.allSettled(
      assets.map((v) =>
        apiMarketplaceItemAssetsDelete({
          item_id: item.id,
          category_id: item.category_id,
          asset: v,
        })
      )
    );

    results.forEach((r) => {
      if (r.status === "rejected") {
        console.error(r.reason);
      }
    });

    wait.start(Wait.MARKETPLACE_ITEM_ASSET_DELETE);
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_ASSET_DELETE);
  }
};

const updateItem = async (params: {
  item: MarketplaceItem;
  assetsCreate: PartialMarketplaceItemAsset[];
  assetsDelete: MarketplaceItemAsset[];
}) => {
  try {
    wait.start(Wait.MARKETPLACE_ITEM_UPDATE);

    const updatedItem = await apiMarketplaceItemsUpdate({
      item: params.item,
      category_id: itemModal.value.category_id,
    });

    await createAssets({ item: updatedItem, assets: params.assetsCreate });
    await deleteAssets({ item: updatedItem, assets: params.assetsDelete });

    itemModal.value = undefined;
    await fetchItemTree();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_UPDATE);
  }
};

const deleteItem = async (params: MarketplaceItem) => {
  try {
    await deleteItemModal.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_ITEM_DELETE);
    await apiMarketplaceItemsDelete(params);
    await fetchItemTree();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_DELETE);
  }
};

fetchItemTree();
</script>

<style module>
.hidden {
  visibility: hidden;
}
</style>
