<template>
  <div :class="[$style.list, { [$style.child]: child }]">
    <Dropdown
      v-for="item in items"
      :ref="(r: any) => dropdownRefs[item.text] = r"
      :key="item.text"
    >
      <template #trigger>
        <div
          :class="$style.item"
          @click="item.children?.length ? null : handleClickItem(item)"
        >
          {{ item.text }}
        </div>
      </template>

      <List
        v-if="item.children"
        child
        :items="item.children"
        @click:item="handleClickItem($event)"
      />
    </Dropdown>
  </div>
</template>

<script setup lang="ts">
import { PropType, defineOptions, ref } from "vue";
import Dropdown from "~/components/Dropdown.vue";

type Item = Record<any, any>;

defineOptions({ name: "List", inheritAttrs: false });

defineProps({
  items: {
    type: Array as PropType<Item[]>,
    default: () => [],
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
