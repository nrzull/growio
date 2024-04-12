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

  <PageShape>
    <template #heading> Items </template>

    <template #tools>
      <Button
        size="sm"
        icon="plus"
        @click="
          itemModal = buildPartialMarketplaceItem({
            category_id: activeCategory?.id!,
          })
        "
      >
        Create
      </Button>
    </template>

    <div :class="[$style.grid, { [$style.empty]: !categories.length }]">
      <Shape v-if="categories.length" type="secondary" :class="$style.aside">
        <Button
          v-for="category in categories"
          :key="category.id"
          size="md"
          :active="activeCategory?.id === category.id"
          type="neutral"
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
        <Table
          v-else
          :table="table"
          clickable
          @click:row="itemModal = $event.original"
        >
          <template #actions="{ ctx }">
            <Icon
              value="trashCircle"
              @click.stop="deleteItem(ctx.row.original)"
            />
          </template>
        </Table>
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
import Icon from "~/components/Icon.vue";
import PromiseModal from "~/components/PromiseModal.vue";

import Shape from "~/components/Shape.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Notification from "~/components/Notifications/Notification.vue";
import { apiMarketplaceItemCategoriesGetAll } from "~/api/growio/marketplace_item_categories";
import { MarketplaceItemCategory } from "~/api/growio/marketplace_item_categories/types";
import {
  MarketplaceItem,
  PartialMarketplaceItem,
} from "~/api/growio/marketplace_items/types";
import {
  apiMarketplaceItemsGetAll,
  apiMarketplaceItemsCreate,
  apiMarketplaceItemsUpdate,
  apiMarketplaceItemsDelete,
} from "~/api/growio/marketplace_items";
import ItemModal from "~/components/Inventory/ItemModal.vue";
import { buildPartialMarketplaceItem } from "~/api/growio/marketplace_items/utils";
import { isMarketplaceItem } from "~/api/growio/marketplace_items/utils";
import {
  MarketplaceItemAsset,
  PartialMarketplaceItemAsset,
} from "~/api/growio/marketplace_item_assets/types";

import {
  apiMarketplaceItemAssetsCreate,
  apiMarketplaceItemAssetsDelete,
} from "~/api/growio/marketplace_item_assets";

const items = ref<MarketplaceItem[]>([]);
const categories = ref<MarketplaceItemCategory[]>([]);
const activeCategory = ref<MarketplaceItemCategory>();
const itemModal = ref<PartialMarketplaceItem | MarketplaceItem>();
const deleteItemModal = ref<InstanceType<typeof PromiseModal>>();

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ITEM_CATEGORIES_FETCH,
    Wait.MARKETPLACE_ITEM_CREATE,
    Wait.MARKETPLACE_ITEM_UPDATE,
    Wait.MARKETPLACE_ITEM_DELETE,
    Wait.MARKETPLACE_ITEM_ASSET_CREATE,
    Wait.MARKETPLACE_ITEM_ASSET_DELETE,
  ])
);

const isEmpty = computed(() => !isLoading.value && !items.value.length);

const columnHelper = createColumnHelper<any>();

const columns = ref([
  columnHelper.accessor("name", {
    cell: (info) => info.getValue(),
    header: () => "Name",
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
    await fetchMarketplaceItems();
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
    await fetchMarketplaceItems();
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
    await fetchMarketplaceItems();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ITEM_DELETE);
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
