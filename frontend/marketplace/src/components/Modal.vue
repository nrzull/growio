<template>
  <div :class="$style.wrapper" @mousedown.self="$emit('close')">
    <Shape :class="$style.shape">
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
import Shape from "~/components/Shape.vue";

defineEmits(["close"]);
</script>

<style module>
.wrapper {
  position: fixed;
  left: 0;
  top: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.02);
  z-index: var(--z-index-modal);
  display: flex;
  justify-content: center;
  align-items: center;
  backdrop-filter: blur(8px);
}

.heading {
  font-size: 21px;
  user-select: none;
}

.shape {
  min-width: 640px;
  display: flex;
  flex-flow: column;
  gap: 24px;
}

.footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
