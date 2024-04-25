<template>
  <PageShape>
    <template #heading>
      <slot name="heading"></slot>
    </template>

    <template #subheading>
      <slot name="subheading"></slot>
    </template>

    <template #tools>
      <Button
        v-if="selectedItems.length"
        size="md"
        icon="cart"
        @click="$router.push(`/${payloadKey}/cart`)"
      >
        {{ selectedItems.length }}
      </Button>
    </template>

    <RouterView :key="categoryId" v-slot="{ Component }">
      <component
        :is="Component"
        v-model:selected-items="selectedItems"
        :payload="payload"
      />
    </RouterView>
  </PageShape>
</template>

<script setup lang="ts">
import { PropType, computed } from "vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import { useLocalStorage } from "@vueuse/core";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";
import Button from "@growio/shared/components/Button.vue";
import { useRoute } from "vue-router";
import { MarketplacePayload } from "@growio/shared/api/growio/customers/types";

defineProps({
  loading: {
    type: Boolean,
    default: false,
  },

  payload: {
    type: Object as PropType<MarketplacePayload>,
    required: true,
  },
});

const route = useRoute();
const payloadKey = route.params.payload as string;
const categoryId = computed(() => route.params.categoryId as string);
const selectedItems = useLocalStorage<MarketplaceItem[]>(payloadKey, []);
</script>
