<template>
  <button :class="[$style.button, $style[size], $style[type]]">
    <img v-if="icon" :class="$style.icon" :src="icon" />
    <slot />
  </button>
</template>

<script setup lang="ts">
import { PropType } from "vue";

defineProps({
  size: {
    type: String as PropType<"sm" | "md">,
    default: "md",
  },

  type: {
    type: String as PropType<"primary" | "neutral">,
    default: "primary",
  },

  icon: {
    type: String,
    default: "",
  },
});
</script>

<style module>
.button {
  all: unset;
  user-select: none;
  box-sizing: border-box;

  border: 1px solid transparent;
  border-radius: 6px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  transition: all 0.2s ease;
  font-weight: 500;
}

.button:not(:disabled) {
  cursor: pointer;
}

.button.md {
  padding: 16px;
}

.button.md .icon {
  height: 16px;
  min-width: 16px;
}

.button.sm {
  padding: 8px 12px;
  font-size: 13px;
}

.button.sm .icon {
  height: 12px;
  min-width: 12px;
}

.button:disabled {
  background-color: var(--color-gray-200);
}

.button:not(:disabled).primary {
  background-color: var(--color-primary);
}

.button:not(:disabled).primary:hover {
  background-color: var(--color-primary-hover);
}

.button:not(:disabled).neutral {
  color: var(--color-black);
}

.button:not(:disabled).neutral:hover {
  color: var(--color-gray-600);
}
</style>
