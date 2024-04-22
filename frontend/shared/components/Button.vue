<template>
  <button
    :class="[
      $style.button,
      $style[size],
      $style[type],
      { [$style.active]: active },
    ]"
  >
    <Icon v-if="icon" :size="size" :value="icon" />
    <slot />
  </button>
</template>

<script setup lang="ts">
import { PropType } from "vue";
import Icon, { Icons } from "@growio/shared/components/Icon.vue";

defineProps({
  size: {
    type: String as PropType<"sm" | "md" | "lg">,
    default: "lg",
  },

  type: {
    type: String as PropType<"primary" | "neutral" | "link-neutral">,
    default: "primary",
  },

  active: {
    type: Boolean,
    default: false,
  },

  icon: {
    type: String as PropType<Icons>,
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

.button.lg {
  padding: 16px;
}

.button.md {
  padding: 12px 16px;
  font-size: 14px;
}

.button.sm {
  padding: 8px 12px;
  font-size: 13px;
}

.button:disabled:not(.link-neutral) {
  background-color: var(--color-gray-200);
}

.button:not(:disabled).primary {
  background-color: var(--color-primary);
}

.button:not(:disabled).primary:hover {
  background-color: var(--color-primary-hover);
}

.button:not(:disabled).neutral.active,
.button:not(:disabled).neutral:hover {
  background-color: var(--color-gray-50);
}

.button:not(:disabled).link-neutral {
  color: var(--color-black);
}

.button:not(:disabled).link-neutral:hover {
  color: var(--color-gray-600);
}
</style>
