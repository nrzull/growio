<template>
  <div :class="$style.page">
    <Tabs v-if="categoryId">
      <Button
        type="neutral"
        size="md"
        icon="arrowBack"
        @click="$router.push(`/${payloadKey}/categories`)"
      >
      </Button>

      <Button
        v-for="category in getCategoryAncestors({ findCategory, categoryId })"
        :key="category.id"
        type="neutral"
        size="md"
        :active="categoryId === category.id"
        @click="$router.push(`/${payloadKey}/categories/${category.id}`)"
      >
        {{ category.name }}
      </Button>
    </Tabs>

    <div :class="$style.top">
      <div>
        <div :class="$style.name">
          {{ item.name }}
        </div>

        <div :class="$style.price">
          {{
            formatPrice({
              price: item.price,
              quantity: 1,
              currency: payload.marketplace.currency,
            })
          }}
        </div>
      </div>

      <div :class="$style.cartButtonsWrapper">
        <div v-if="isSelected(item)" :class="$style.cartButtons">
          <Button
            size="md"
            active
            icon="minusCircle"
            type="neutral"
            @click="decrement(item)"
          ></Button>
          <span>{{ getSelected(item).quantity }}</span>
          <Button
            size="md"
            active
            icon="plus"
            type="neutral"
            @click="increment(item)"
          ></Button>
        </div>
        <Button
          v-else
          size="md"
          :class="$style.cartButton"
          @click="addItem(item)"
        >
          Add to Cart
        </Button>
      </div>
    </div>

    <div v-if="item" :class="$style.item">
      <div :class="$style.images">
        <swiper-container
          v-if="item.assets.length"
          :class="$style.images"
          :slides-per-view="1"
          :pagination="true"
          :pagination-clickable="true"
          direction="vertical"
        >
          <swiper-slide v-for="asset in item.assets" :key="asset.id">
            <img :class="$style.image" :src="asset.src" />
          </swiper-slide>
        </swiper-container>
      </div>

      <div :class="$style.main">
        <div :class="$style.description">
          <div :class="$style.subheading">Описание</div>
          {{ item.description || "-" }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import { useCart } from "~/composables/useCart";
import {
  buildFindCategory,
  getCategoryAncestors,
  buildFindItem,
} from "~/utils/category";
import Button from "@growio/shared/components/Button.vue";
import Tabs from "@growio/shared/components/Tabs.vue";
import { formatPrice } from "@growio/shared/utils/money";
import { payload } from "~/composables/payload";

const route = useRoute();
const payloadKey = route.params.payload as string;

const categoryId = computed(() =>
  route.params.categoryId ? Number(route.params.categoryId) : undefined
);

const itemId = computed(() =>
  route.params.itemId ? Number(route.params.itemId) : undefined
);

const item = computed(() =>
  itemId.value ? findItem(itemId.value) : undefined
);

const findCategory = buildFindCategory(() => payload.value.items);
const findItem = buildFindItem(() => payload.value.items);

const { isSelected, increment, decrement, getSelected, addItem } = useCart({
  key: payloadKey,
  items: computed(() => payload.value.items),
});
</script>

<style module>
.page {
  display: flex;
  flex-flow: column;
  gap: 24px;
}

.item {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.name {
  font-size: 32px;
  font-weight: 400;
  line-height: 1.33;
  overflow-wrap: anywhere;
}

.price {
  font-size: 28px;
  font-weight: 700;
  display: inline-flex;
  width: max-content;
  border-radius: 8px;
}

.description {
  display: grid;
  gap: 8px;
}

.subheading {
  font-weight: 500;
  font-size: 21px;
}

.image {
  width: 100%;
  object-fit: contain;
}

.main {
  display: flex;
  flex-flow: column;
  gap: 24px;
}

.images {
  height: 320px;
}

.cartButtonsWrapper {
  width: 100%;
}

.cartButtons {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24px;
}

.cartButton {
  width: 100%;
}

.top {
  display: grid;
  grid-template-columns: 3fr 1fr;
  gap: 24px;
}
</style>
