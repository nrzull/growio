<template>
  <div :class="$style.wrapper" @mousedown.self="$emit('close')">
    <Shape :class="[$style.shape, $style[size]]">
      <slot name="loader">
        <ElementLoader :loading="loading" />
      </slot>

      <div :class="$style.heading">
        <slot name="heading"></slot>
      </div>

      <slot></slot>

      <div :class="$style.footer">
        <slot name="footer"></slot>
      </div>
    </Shape>
  </div>
</template>

<script setup lang="ts">
import { PropType } from "vue";
import Shape from "@growio/shared/components/Shape.vue";
import ElementLoader from "@growio/shared/components/ElementLoader.vue";
import { useModal } from "@growio/shared/components/Modal/useModal";

defineEmits(["close"]);

defineProps({
  size: {
    type: String as PropType<"md" | "lg">,
    default: "md",
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const { zIndex } = useModal();
</script>

<style module>
.wrapper {
  position: fixed;
  left: 0;
  top: 0;
  width: 100vw;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.02);
  z-index: v-bind(zIndex);
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
  display: flex;
  align-items: center;
  gap: 8px;
}

.shape {
  display: flex;
  flex-flow: column;
  gap: 24px;
  position: relative;
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
