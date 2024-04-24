<template>
  <div :class="$style.inventory">
    <Tabs v-if="proxyParent">
      <Button
        type="neutral"
        :class="$style.heading"
        size="md"
        @click="proxyParent = undefined"
      >
        Главная
      </Button>

      <Button
        v-for="ancestor in getParentAncestors()"
        :key="ancestor.id"
        type="neutral"
        :class="$style.heading"
        size="md"
        :active="proxyParent.id === ancestor.id"
        @click="proxyParent = ancestor"
      >
        {{ ancestor.name }}
      </Button>
    </Tabs>

    <div :class="$style.shapes">
      <Shape
        v-for="category in categories"
        :key="category.id"
        :class="$style.shape"
        type="secondary"
        @click="proxyParent = category"
      >
        {{ category.name }}
      </Shape>

      <Shape
        v-for="item in activeItems"
        :key="item.id"
        :class="$style.shape"
        type="secondary"
      >
        {{ item.name }}
      </Shape>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import {
  MarketplaceItemsTree,
  MarketplaceTreeItemCategory,
} from "@growio/shared/api/growio/marketplace_items_tree/types";
import { PropType } from "vue";
import { isMarketplaceTreeItemCategory } from "@growio/shared/api/growio/marketplace_items_tree/utils";
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";
import { clone } from "remeda";
import Shape from "@growio/shared/components/Shape.vue";
import Button from "@growio/shared/components/Button.vue";
import Tabs from "@growio/shared/components/Tabs.vue";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  modelValue: {
    type: Array as PropType<MarketplaceItem[]>,
    default: () => [],
  },

  items: {
    type: Array as PropType<MarketplaceItemsTree>,
    default: () => [],
  },

  parent: {
    type: Object as PropType<MarketplaceTreeItemCategory>,
    default: undefined,
  },
});

const emit = defineEmits({
  "update:model-value": (_v: MarketplaceItem[]) => true,
});

const proxyParent = ref<MarketplaceTreeItemCategory>(clone(props.parent));

const inventory = computed(() =>
  proxyParent.value ? proxyParent.value.children : props.items
);

const categories = computed(() =>
  inventory.value.filter(isMarketplaceTreeItemCategory)
);

const activeItems = computed(() =>
  inventory.value.filter((v) => !isMarketplaceTreeItemCategory(v))
);

const getParentAncestors = () => {
  if (!proxyParent.value) {
    return [];
  }

  const ancestors = [];

  const executor = (parent = proxyParent.value) => {
    const target = findAncestor(parent?.parent_id);

    if (target) {
      ancestors.unshift(target);
      executor(target);
    }
  };

  executor();

  return ancestors.concat(proxyParent.value);
};

const findAncestor = (id: number) => {
  const executor = (children = props.items) => {
    const r = children
      .filter(isMarketplaceTreeItemCategory)
      .map((v) => (v.id === id ? v : executor(v.children)));

    return r.flat();
  };

  const [nextParent] = executor();

  return nextParent;
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
</style>
