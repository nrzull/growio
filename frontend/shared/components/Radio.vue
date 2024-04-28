<template>
  <Checkbox v-bind="$props" v-model="proxyModelValue">
    <template #default>
      <slot></slot>
    </template>
  </Checkbox>
</template>

<script setup lang="ts" generic="T">
import Checkbox from "@growio/shared/components/Checkbox.vue";
import { computed } from "vue";
import { equals } from "remeda";

const props = defineProps<{
  modelValue: T;
  option: T;
  readonly?: boolean;
}>();

const emit = defineEmits({ "update:model-value": (_v: T) => true });

const proxyModelValue = computed({
  get: () => equals(props.modelValue, props.option),
  set: (v) => v && emit("update:model-value", props.option),
});
</script>
