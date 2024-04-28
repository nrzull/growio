<template>
  <div
    :class="$style.checkbox"
    @click="readonly ? null : (proxyModelValue = !proxyModelValue)"
  >
    <div :class="[$style.body, { [$style.checked]: proxyModelValue }]">
      <div v-if="proxyModelValue" :class="$style.marker"></div>
    </div>

    <slot></slot>
  </div>
</template>

<script setup lang="ts">
defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },

  readonly: {
    type: Boolean,
    default: false,
  },
});

const proxyModelValue = defineModel<boolean>("modelValue", { default: false });
</script>

<style module>
.checkbox {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  user-select: none;
  width: max-content;
}

.body {
  display: inline-flex;
  justify-content: center;
  align-items: center;
  width: 16px;
  height: 16px;
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-gray-100);
  border-radius: 2px;
}

.body.checked {
  background-color: var(--color-primary);
  border-color: transparent;
}

.checkbox:not(.readonly) {
  cursor: pointer;
}

.marker {
  width: 50%;
  height: 50%;
  background-color: var(--color-black);
  border-radius: 2px;
}
</style>
