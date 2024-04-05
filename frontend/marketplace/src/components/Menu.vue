<template>
  <Dropdown
    ref="dropdownRef"
    :manual
    @click:trigger="$emit('click:trigger', $event)"
  >
    <template #trigger>
      <slot></slot>
    </template>

    <List
      :items
      :track-by
      :label-path
      :children-path
      @click:item="handleClickItem"
    />
  </Dropdown>
</template>

<script setup lang="ts">
import { ref, PropType, computed } from "vue";
import List from "~/components/Menu/List.vue";
import Dropdown from "~/components/Dropdown.vue";
import { itemsProp } from "~/components/Menu/utils";
import { Item } from "~/components/Menu/types";

defineProps({
  items: itemsProp,

  trackBy: {
    type: String,
    default: undefined,
  },

  labelPath: {
    type: String,
    default: undefined,
  },

  childrenPath: {
    type: String,
    default: undefined,
  },

  manual: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits({
  "click:item": (_v: Item) => true,
  "click:trigger": (_v: boolean) => true,
});

const dropdownRef = ref<InstanceType<typeof Dropdown>>();
const open = computed(() => dropdownRef.value?.open);
const setOpen = computed(() => dropdownRef.value?.setOpen);

const handleClickItem = (v: Item) => {
  dropdownRef.value?.setOpen?.(false);
  emit("click:item", v);
};

defineExpose({ open, setOpen });
</script>
