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
      <component :is="Component" :payload="payload" />
    </RouterView>
  </PageShape>
</template>

<script setup lang="ts">
import { computed } from "vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import Button from "@growio/shared/components/Button.vue";
import { useRoute } from "vue-router";
import { useCart } from "~/composables/useCart";
import { payload } from "~/composables/payload";

const route = useRoute();
const payloadKey = route.params.payload as string;
const categoryId = computed(() => route.params.categoryId as string);
const { selectedItems } = useCart({
  key: payloadKey,
  items: computed(() => payload.value.items),
});
</script>
