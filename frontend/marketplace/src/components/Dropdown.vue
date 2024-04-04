<template>
  <div :class="$style.dropdown">
    <div ref="triggerRef" :class="$style.trigger" @click="open = !open">
      <slot name="trigger"></slot>
    </div>

    <div
      v-if="open"
      ref="floatingRef"
      :style="floatingStyles"
      :class="$style.floating"
    >
      <slot></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { useFloating, autoUpdate } from "@floating-ui/vue";

const open = ref(false);
const triggerRef = ref<HTMLDivElement>();
const floatingRef = ref<HTMLDivElement>();

const setOpen = (v: boolean) => (open.value = v);

const minWidth = computed(() => {
  const value = triggerRef.value?.getBoundingClientRect()?.width;

  if (typeof value === "number") {
    return `${value}px`;
  }
});

const { floatingStyles } = useFloating(triggerRef, floatingRef, {
  whileElementsMounted: autoUpdate,
  open,
});

defineExpose({ setOpen });
</script>

<style module>
.trigger {
  cursor: pointer;
}

.floating {
  min-width: v-bind(minWidth);
}
</style>
