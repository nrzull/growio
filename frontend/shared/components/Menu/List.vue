<template>
  <div :class="[$style.list, { [$style.child]: child }]">
    <Dropdown
      v-for="(item, i) in items"
      :ref="(r: any) => (dropdownRefs[getKey(item, trackBy, i)] = r)"
      :key="getKey(item, trackBy, i)"
    >
      <template #trigger>
        <div
          :class="$style.item"
          @mousedown="
            getChildren(item, childrenPath)?.length
              ? null
              : handleClickItem(item)
          "
        >
          {{ getLabel(item, labelPath) }}
        </div>
      </template>

      <List
        v-if="getChildren(item, childrenPath)"
        child
        :track-by
        :label-path
        :children-path
        :items="getChildren(item, childrenPath)"
        @click:item="handleClickItem($event)"
      />
    </Dropdown>
  </div>
</template>

<script setup lang="ts">
import { defineOptions, ref } from "vue";
import Dropdown from "@growio/shared/components/Dropdown.vue";
import {
  itemsProp,
  getLabel,
  getKey,
  getChildren,
} from "@growio/shared/components/Menu/utils";
import { Item } from "@growio/shared/components/Menu/types";

defineOptions({ name: "List", inheritAttrs: false });

defineProps({
  items: itemsProp,

  trackBy: {
    type: String,
    default: "id",
  },

  labelPath: {
    type: String,
    default: "title",
  },

  childrenPath: {
    type: String,
    default: "children",
  },

  child: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits({ "click:item": (_v: Item) => true });

const dropdownRefs = ref<Record<string, InstanceType<typeof Dropdown>>>({});

const handleClickItem = (v: Item) => {
  for (const dropdownRef of Object.values(dropdownRefs.value)) {
    dropdownRef.setOpen(false);
  }

  emit("click:item", v);
};
</script>

<style module>
.list {
  padding: 8px 0;
  display: flex;
  flex-flow: column;
  background-color: var(--color-white);
  box-shadow: 0 4px 24px hsla(0, 0%, 0%, 2%);
  border: 1px solid hsla(0, 0%, 0%, 10%);
  border-radius: 8px;
}

.item {
  padding: 8px 24px;
  user-select: none;
  width: 100%;
}
</style>
