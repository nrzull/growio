<template>
  <div :class="$style.loader">
    <div />
    <div />
    <div />
    <div />
    <div />
    <div />
    <div />
    <div />
    <div />
  </div>
</template>

<script setup lang="ts">
import { defineProps } from "vue";

defineProps({
  color: {
    type: String,
    default: "var(--color-primary)",
  },
});
</script>

<style module>
.loader {
  display: flex;
  position: relative;
  width: 52px;
  height: 52px;
}

.loader div {
  position: absolute;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: v-bind(color);
  animation: loader_fade 1.2s linear infinite, loader_scale 1.2s linear infinite;
}

.loader div:nth-child(1) {
  animation-delay: -1.13s;
  top: 0px;
  left: 0px;
}

.loader div:nth-child(2) {
  animation-delay: -1.16s;
  top: 19px;
  left: 0px;
}

.loader div:nth-child(3) {
  animation-delay: -0.31s;
  top: 38px;
  left: 0px;
}

.loader div:nth-child(4) {
  animation-delay: -0.85s;
  top: 0px;
  left: 19px;
}

.loader div:nth-child(5) {
  animation-delay: -1.04s;
  top: 19px;
  left: 19px;
}

.loader div:nth-child(6) {
  animation-delay: -0.52s;
  top: 38px;
  left: 19px;
}

.loader div:nth-child(7) {
  animation-delay: -0.51s;
  top: 0px;
  left: 38px;
}

.loader div:nth-child(8) {
  animation-delay: -0.96s;
  top: 19px;
  left: 38px;
}

.loader div:nth-child(9) {
  animation-delay: -0.73s;
  top: 38px;
  left: 38px;
}

@keyframes loader_fade {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.54;
  }
}

@keyframes loader_scale {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(0.77);
  }
}
</style>
