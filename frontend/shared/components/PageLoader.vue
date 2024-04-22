<template>
  <Teleport to="#main">
    <section :class="['pageLoader', { visible: loading }]">
      <LoaderIcon />
    </section>
  </Teleport>
</template>

<script setup lang="ts">
import LoaderIcon from "@growio/shared/components/LoaderIcon.vue";

defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
});
</script>

<style>
.pageLoader {
  position: absolute;
  height: 100%;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-flow: column;
  opacity: 0;
  visibility: hidden;
  z-index: var(--z-index-page-loader);
  background-color: hsl(0, 100%, 100%);
  border-radius: 8px;
}

.pageLoader.visible {
  opacity: 1;
  visibility: visible;
}

#main:has(.pageLoader.visible) {
  z-index: unset;
}
</style>
