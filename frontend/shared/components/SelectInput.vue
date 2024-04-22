<template>
  <Menu
    ref="menuRef"
    manual
    :items
    :track-by
    :label-path
    :children-path
    @click:item="proxyModelValue = $event"
  >
    <TextInput
      v-bind="$attrs"
      readonly
      :model-value="getLabel(proxyModelValue, labelPath)"
      @focus="!readonly && items.length && menuRef.setOpen(true)"
      @blur="menuRef.setOpen(false)"
    />
  </Menu>
</template>

<script setup lang="ts">
import { PropType, ref, computed } from "vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import Menu from "@growio/shared/components/Menu.vue";
import { Item } from "@growio/shared/components/Menu/types";
import { itemsProp } from "@growio/shared/components/Menu/utils";
import { getLabel } from "@growio/shared/components/Menu/utils";
import { ComponentExposed } from "@growio/shared/types";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  modelValue: {
    type: [String, Number, Object, null, undefined] as PropType<Item>,
    default: undefined,
  },

  items: itemsProp,

  trackBy: {
    type: String,
    default: undefined,
  },

  readonly: {
    type: Boolean,
    default: false,
  },

  labelPath: {
    type: String,
    default: undefined,
  },

  childrenPath: {
    type: String,
    default: undefined,
  },
});

const emit = defineEmits(["update:model-value"]);

const menuRef = ref<ComponentExposed<typeof Menu<Item>>>();

const proxyModelValue = computed({
  get: () => props.modelValue,
  set: (v) => emit("update:model-value", v),
});
</script>
