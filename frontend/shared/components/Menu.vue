<template>
  <Dropdown
    ref="dropdownRef"
    :manual
    :floating-class="$style.menu"
    :use-floating-options="useFloatingOptions"
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

<script setup lang="ts" generic="T extends Item">
import { ref, computed, PropType } from "vue";
import List from "@growio/shared/components/Menu/List.vue";
import Dropdown from "@growio/shared/components/Dropdown.vue";
import { Item } from "@growio/shared/components/Menu/types";
import { UseFloatingOptions } from "@floating-ui/vue";

defineProps({
  items: {
    type: Array as PropType<T[]>,
    default: () => [],
  },

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

  useFloatingOptions: {
    type: Object as PropType<UseFloatingOptions>,
    default: undefined,
  },
});

const emit = defineEmits({
  "click:item": (_v: T) => true,
  "click:trigger": (_v: boolean) => true,
});

const dropdownRef = ref<InstanceType<typeof Dropdown>>();
const open = computed(() => dropdownRef.value?.open);
const setOpen = computed(() => dropdownRef.value?.setOpen);

const handleClickItem = (v: T) => {
  dropdownRef.value?.setOpen?.(false);
  emit("click:item", v);
};

defineExpose({ open, setOpen });
</script>

<style module>
.menu {
  z-index: var(--z-index-menu);
}
</style>
