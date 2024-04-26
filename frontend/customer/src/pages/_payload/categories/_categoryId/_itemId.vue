<template>
  <div :class="$style.itemId">
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

    <div v-if="item" :class="$style.item">
      <ImagePreview :class="$style.imagePreview" :model-value="item" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { MarketplacePayload } from "@growio/shared/api/growio/customers/types";
import { PropType, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useCart } from "~/composables/useCart";
import {
  buildFindCategory,
  getCategoryAncestors,
  buildFindItem,
} from "~/utils/category";
import Button from "@growio/shared/components/Button.vue";
import Tabs from "@growio/shared/components/Tabs.vue";
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

const categoryId = computed(() =>
  route.params.categoryId ? Number(route.params.categoryId) : undefined
);

const itemId = computed(() =>
  route.params.itemId ? Number(route.params.itemId) : undefined
);

const item = computed(() =>
  itemId.value ? findItem(itemId.value) : undefined
);

const findCategory = buildFindCategory(() => props.payload.items);
const findItem = buildFindItem(() => props.payload.items);

const {} = useCart({ key: payloadKey });
</script>

<style module>
.itemId {
  display: grid;
  gap: 12px;
}

.item {
  display: grid;
  gap: 12px;
}

.imagePreview {
  height: 480px;
}
</style>
