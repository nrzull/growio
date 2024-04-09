<template>
  <section :class="[$style.elementLoader, { [$style.visible]: loading }]">
    <LoaderIcon />
  </section>
</template>

<script setup lang="ts">
import LoaderIcon from "~/components/LoaderIcon.vue";

defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
});
</script>

<style module>
.elementLoader {
  position: absolute;
  height: 100%;
  width: 100%;
  left: 0;
  top: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-flow: column;
  opacity: 0;
  visibility: hidden;
  z-index: var(--z-index-element-loader);
  background-color: hsl(0, 100%, 100%);
  border-radius: 8px;
}

.elementLoader.visible {
  opacity: 1;
  visibility: visible;
}
</style>
