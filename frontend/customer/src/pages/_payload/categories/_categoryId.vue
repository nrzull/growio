<template>
  <div :class="$style.inventory">
    <Tabs v-if="categoryId">
      <Button
        type="neutral"
        :class="$style.heading"
        size="md"
        icon="arrowBack"
        @click="categoryId = undefined"
      >
      </Button>

      <Button
        v-for="category in getCategoryAncestors()"
        :key="category.id"
        type="neutral"
        :class="$style.heading"
        size="md"
        :active="categoryId === category.id"
        @click="categoryId = category.id"
      >
        {{ category.name }}
      </Button>
    </Tabs>

    <Notification
      v-if="!(categories.length + activeItems.length)"
      :model-value="{ text: 'No items', type: 'info' }"
    />
    <div v-else :class="$style.shapes">
      <Shape
        v-for="category in categories"
        :key="category.id"
        :class="$style.shape"
        type="secondary"
        @click="categoryId = category.id"
      >
        {{ category.name }}
      </Shape>

      <Shape
        v-for="item in activeItems"
        :key="item.id"
        :class="[$style.shape, { [$style.toggled]: isToggled(item) }]"
        type="secondary"
        @click="toggleItem(item)"
      >
        {{ item.name }}
      </Shape>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { MarketplaceTreeItemCategory } from "@growio/shared/api/growio/marketplace_items_tree/types";
import { PropType } from "vue";
import { isMarketplaceTreeItemCategory } from "@growio/shared/api/growio/marketplace_items_tree/utils";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";

import Shape from "@growio/shared/components/Shape.vue";
import Button from "@growio/shared/components/Button.vue";
import Tabs from "@growio/shared/components/Tabs.vue";
import { isMarketplaceItem } from "@growio/shared/api/growio/marketplace_items/utils";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import { MarketplacePayload } from "@growio/shared/api/growio/customers/types";
import { useRoute, useRouter } from "vue-router";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  payload: {
    type: Object as PropType<MarketplacePayload>,
    required: true,
  },

  selectedItems: {
    type: Array as PropType<MarketplaceItem[]>,
    default: () => [],
  },
});

const route = useRoute();
const router = useRouter();

const payloadKey = route.params.payload as string;

const categoryId = computed({
  get: () =>
    route.params.categoryId ? Number(route.params.categoryId) : undefined,
  set: (v) => router.push(`/${payloadKey}/categories/${v || ""}`),
});

const proxySelectedItems = defineModel<MarketplaceItem[]>("selectedItems", {
  required: true,
});

const inventory = computed(
  () =>
    (categoryId.value
      ? findCategory(categoryId.value)?.children
      : props.payload.items) || []
);

const categories = computed(() =>
  inventory.value.filter(isMarketplaceTreeItemCategory)
);

const activeItems = computed(() => inventory.value.filter(isMarketplaceItem));

const toggleItem = (item: MarketplaceItem) => {
  if (isToggled(item)) {
    proxySelectedItems.value = proxySelectedItems.value.filter(
      (v) => v.id !== item.id
    );
  } else {
    proxySelectedItems.value.push({ ...item, quantity: 1 });
  }
};

const isToggled = (item: MarketplaceItem) =>
  proxySelectedItems.value.some((v) => v.id === item.id);

const getCategoryAncestors = () => {
  if (!categoryId.value) {
    return [];
  }

  const category = findCategory(categoryId.value);

  const ancestors = [];

  const executor = (parent = category) => {
    const target = findCategory(parent?.parent_id);

    if (target) {
      ancestors.unshift(target);
      executor(target);
    }
  };

  executor();

  return ancestors.concat(category);
};

const findCategory = (id: number) => {
  const executor = (
    children = props.payload.items
  ): MarketplaceTreeItemCategory[] => {
    const r = children
      .filter(isMarketplaceTreeItemCategory)
      .map((v) => (v.id === id ? v : executor(v.children)));

    return r.flat();
  };

  const [foundCategory] = executor();

  return foundCategory;
};
</script>

<style module>
.inventory {
  display: grid;
  gap: 12px;
}

.heading {
  font-weight: 500;
}

.shapes {
  display: grid;
  gap: 8px;
  grid-template-columns: 1fr 1fr 1fr;
}

.shape {
  cursor: pointer;
}

.shape.toggled {
  border-color: var(--color-primary);
}
</style>
