<template>
  <div :class="$style.inventory">
    <Tabs v-if="categoryId">
      <Button
        type="neutral"
        size="md"
        icon="arrowBack"
        @click="categoryId = undefined"
      >
      </Button>

      <Button
        v-for="category in getCategoryAncestors({ findCategory, categoryId })"
        :key="category.id"
        type="neutral"
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
          <ImagePreview
            :model-value="item"
            :class="$style.imagePreview"
            @click="
              $router.push(
                `/${payloadKey}/categories/${item.category_id}/items/${item.id}`
              )
            "
          />

          <div :class="$style.itemPrice">
            {{
              formatPrice({
                price: item.price,
                quantity: 1,
                currency: payload.marketplace.currency,
              })
            }}
          </div>

          <div :class="$style.itemTitle">
            {{ item.name }}
          </div>

          <div v-if="isSelected(item)" :class="$style.itemButtons">
            <Button
              type="neutral"
              size="md"
              icon="minusCircle"
              active
              @click="decrement(item)"
            ></Button>
            <span>{{ getSelected(item).quantity }}</span>
            <Button
              type="neutral"
              size="md"
              icon="plus"
              active
              @click="increment(item)"
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
import { PropType } from "vue";
import { isMarketplaceTreeItemCategory } from "@growio/shared/api/growio/marketplace_items_tree/utils";
import Shape from "@growio/shared/components/Shape.vue";
import Button from "@growio/shared/components/Button.vue";
import Tabs from "@growio/shared/components/Tabs.vue";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import { MarketplacePayload } from "@growio/shared/api/growio/customers/types";
import { useRoute, useRouter } from "vue-router";
import { useCart } from "~/composables/useCart";
import { formatPrice } from "@growio/shared/utils/money";
import {
  buildFindCategory,
  getCategoryAncestors,
  getItemDescendants,
} from "~/utils/category";
import ImagePreview from "~/components/ImagePreview.vue";

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
  items: computed(() => props.payload.items),
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

const findCategory = buildFindCategory(() => props.payload.items);
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
  padding: 24px 12px;
}

.itemButtons {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.itemPrice {
  font-weight: 700;
  font-size: 18px;
}

.itemTitle {
  flex: 1;
}

.imagePreview {
  cursor: pointer;
}
</style>
