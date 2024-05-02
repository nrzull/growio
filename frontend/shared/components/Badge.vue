<template>
  <Tag :class="[$style.tag, { [$style.visible]: !!modelValue }]">
    {{ modelValue > 99 ? 99 : modelValue }}
  </Tag>
</template>

<script setup lang="ts">
import Tag from "./Tag.vue";

defineProps({
  modelValue: {
    type: Number,
    default: undefined,
  },
});
</script>

<style module>
.tag {
  width: 21px;
  overflow: hidden;
  display: flex;
  justify-content: center;
  align-items: center;
  opacity: 0;
}

.tag.visible {
  opacity: 1;
}
</style>
