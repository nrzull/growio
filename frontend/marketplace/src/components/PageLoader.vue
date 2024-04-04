<template>
  <section :class="$style.pageLoader">
    <LoaderIcon />
  </section>
</template>

<script setup lang="ts">
import LoaderIcon from "~/components/LoaderIcon.vue";
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
}
</style>
