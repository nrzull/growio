<template>
  <section :class="[$style.pageLoader, { [$style.visible]: loading }]">
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
.pageLoader {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-flow: column;
  overflow: hidden;
  background-color: hsla(0, 100%, 100%, 60%);
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
  z-index: var(--z-index-page-loader);
}

.pageLoader.visible {
  opacity: 1;
  visibility: visible;
}
</style>
