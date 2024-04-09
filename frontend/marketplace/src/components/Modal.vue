<template>
  <div :class="$style.wrapper" @mousedown.self="$emit('close')">
    <Shape :class="[$style.shape, $style[size]]">
      <div :class="$style.heading">
        <slot name="heading"></slot>
      </div>

      <div :class="$style.body">
        <slot></slot>
      </div>

      <div :class="$style.footer">
        <slot name="footer"></slot>
      </div>
    </Shape>
  </div>
</template>

<script setup lang="ts">
import { PropType } from "vue";
import Shape from "~/components/Shape.vue";

defineEmits(["close"]);

defineProps({
  size: {
    type: String as PropType<"md" | "lg">,
    default: "md",
  },
});
</script>

<style module>
.wrapper {
  position: fixed;
  left: 0;
  top: 0;
  width: 100vw;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.02);
  z-index: var(--z-index-modal);
  display: flex;
  justify-content: center;
  align-items: center;
  backdrop-filter: blur(8px);
  flex-flow: wrap;
  overflow-y: auto;
  overflow-x: clip;
}

.heading {
  font-size: 21px;
  user-select: none;
}

.body {
  position: relative;
}

.shape {
  display: flex;
  flex-flow: column;
  gap: 24px;
}

.shape.md {
  width: 640px;
}

.shape.lg {
  width: 960px;
}

.footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
