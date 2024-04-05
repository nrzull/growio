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
      @focus="items.length && menuRef.setOpen(true)"
      @blur="menuRef.setOpen(false)"
      readonly
      :model-value="getLabel(proxyModelValue, labelPath)"
    />
  </Menu>
</template>

<script setup lang="ts">
import { PropType, ref, computed } from "vue";
import TextInput from "~/components/TextInput.vue";
import Menu from "~/components/Menu.vue";
import { Item } from "~/components/Menu/types";
import { itemsProp } from "~/components/Menu/utils";
import { getLabel } from "~/components/Menu/utils";

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

const menuRef = ref<InstanceType<typeof Menu>>();

const proxyModelValue = computed({
  get: () => props.modelValue,
  set: (v) => emit("update:model-value", v),
});
</script>
