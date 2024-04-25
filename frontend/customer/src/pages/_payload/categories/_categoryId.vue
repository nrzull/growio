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
    <div v-else :class="$style.main">
      <div :class="$style.categories">
        <Button
          v-for="category in categories"
          :key="category.id"
          :class="$style.shape"
          type="neutral"
          size="sm"
          @click="categoryId = category.id"
        >
          {{ category.name }}
        </Button>
      </div>

      <div :class="$style.items">
        <Shape
          v-for="item in activeItems"
          :key="item.id"
          :class="$style.item"
          type="secondary"
        >
          <div :class="$style.price">
            {{
              formatPrice({
                price: item.price,
                quantity: 1,
                currency: payload.marketplace.currency,
              })
            }}
          </div>

          <div
            :class="$style.itemTitle"
            @click="
              $router.push(
                `/${payloadKey}/categories/${item.category_id}/items/${item.id}`
              )
            "
          >
            {{ item.name }}
          </div>

          <div :class="$style.itemButtons" v-if="isSelected(item)">
            <Button
              type="neutral"
              size="md"
              icon="minusCircle"
              @click="decrement(getSelected(item))"
            ></Button>
            <span>{{ getSelected(item).quantity }}</span>
            <Button
              type="neutral"
              size="md"
              icon="plus"
              @click="increment(getSelected(item))"
            ></Button>
          </div>
          <Button v-else size="md" @click="addItem(item)">Add to Cart</Button>
        </Shape>
      </div>
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
import { useCart } from "~/composables/useCart";
import { formatPrice } from "@growio/shared/utils/money";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  payload: {
    type: Object as PropType<MarketplacePayload>,
    required: true,
  },
});

const route = useRoute();
const router = useRouter();

const payloadKey = route.params.payload as string;

const { increment, decrement, addItem, isSelected, getSelected } = useCart({
  key: payloadKey,
});

const categoryId = computed({
  get: () =>
    route.params.categoryId ? Number(route.params.categoryId) : undefined,
  set: (v) => router.push(`/${payloadKey}/categories/${v || ""}`),
});

const currentCategory = computed(() =>
  categoryId.value ? findCategory(categoryId.value) : undefined
);

const inventory = computed(
  () => currentCategory.value?.children || props.payload.items || []
);

const categories = computed(() =>
  inventory.value.filter(isMarketplaceTreeItemCategory)
);

const activeItems = computed(() =>
  currentCategory.value
    ? getItemDescendants(currentCategory.value)
    : categories.value.map((category) => getItemDescendants(category)).flat()
);

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

const getItemDescendants = (category: MarketplaceTreeItemCategory) => {
  const itemDescendants: MarketplaceItem[] = [];

  const executor = (target = category) => {
    target.children.map((c) => {
      if (isMarketplaceItem(c)) {
        itemDescendants.push(c);
      } else {
        executor(c);
      }
    });
  };

  executor();

  return itemDescendants;
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

.main {
  display: grid;
  gap: 12px;
}

.categories {
  display: flex;
  flex-flow: wrap;
  gap: 8px;
}

.items {
  display: grid;
  gap: 24px;
  grid-template-columns: 1fr 1fr 1fr;
}

.item {
  display: flex;
  flex-flow: column;
  gap: 12px;
  justify-content: space-between;
  padding: 24px 12px;
}

.itemButtons {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.itemTitle {
  width: max-content;
  cursor: pointer;
  transition: color 0.2s ease;
}

.itemTitle:hover {
  color: var(--color-gray-500);
}
</style>
