<template>
  <Dropdown ref="dropdownRef">
    <template #trigger>
      <slot></slot>
    </template>

    <List :items="items" @click:item="handleClickItem" />
  </Dropdown>
</template>

<script setup lang="ts">
import { ref, PropType } from "vue";
import List from "~/components/menu/list.vue";
import Dropdown from "~/components/dropdown.vue";

defineProps({
  items: {
    type: Array as PropType<Record<any, any>[]>,
    default: () => [],
  },
});

const emit = defineEmits({ "click:item": (_v: any) => true });

const dropdownRef = ref<InstanceType<typeof Dropdown>>();

const handleClickItem = (v: Record<any, any>) => {
  dropdownRef.value?.setOpen?.(false);
  emit("click:item", v);
};
</script>
