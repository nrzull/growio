<template>
  <PageShape>
    <template #heading>
      <slot name="heading"></slot>
    </template>

    <template #subheading>
      <slot name="subheading"></slot>
    </template>

    <template #tools>
      <Tag size="md"> {{ payload.order.status }}</Tag>
    </template>

    <div :class="$style.items">
      <Shape
        :class="$style.item"
        type="secondary"
        v-for="item in payload.order.items || []"
        :key="item.id"
      >
        <div>{{ item.name }}</div>
        <div :class="$style.quantity">{{ item.quantity }}</div>
        <div :class="$style.price">
          {{
            formatPrice({
              price: item.price,
              quantity: item.quantity,
              currency: payload.order.currency,
            })
          }}
        </div>
      </Shape>
    </div>
  </PageShape>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import { useCart } from "~/composables/useCart";
import { payload } from "~/composables/payload";
import PageShape from "@growio/shared/components/PageShape.vue";
import Tag from "@growio/shared/components/Tag.vue";
import Shape from "@growio/shared/components/Shape.vue";
import { formatPrice } from "@growio/shared/utils/money";

const route = useRoute();
const payloadKey = route.params.payload as string;

const { selectedItems } = useCart({
  key: payloadKey,
  items: computed(() => payload.value.items),
});

selectedItems.value = null;
</script>

<style module>
.items {
  display: grid;
  gap: 12px;
}

.item {
  display: grid;
  grid-template-columns: 1fr 60px 120px;
  align-items: center;
  gap: 24px;
}

.quantity {
  text-align: right;
}

.price {
  text-align: right;
}
</style>
