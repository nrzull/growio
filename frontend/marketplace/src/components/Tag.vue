<template>
  <div
    :class="[
      $style.tag,
      $style[size],
      { [$style.active]: active, [$style.clickable]: clickable },
    ]"
  >
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
import { PropType } from "vue";

defineProps({
  size: {
    type: String as PropType<"sm" | "md">,
    default: "sm",
  },

  active: {
    type: Boolean,
    default: false,
  },

  clickable: {
    type: Boolean,
    default: false,
  },
});
</script>

<style module>
.tag {
  display: inline-flex;
  border-radius: 8px;

  background-color: var(--color-gray-100);

  font-weight: bold;
  text-transform: uppercase;
  transition: background-color 0.2s ease;
  user-select: none;
}

.tag.sm {
  padding: 2px 8px;
  font-size: 10px;
}

.tag.md {
  padding: 4px 8px;
  font-size: 12px;
}

.tag.active {
  background-color: var(--color-primary);
}

.tag.clickable {
  cursor: pointer;
}
</style>
