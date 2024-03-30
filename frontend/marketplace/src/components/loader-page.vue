<template>
  <section :class="$style.loaderPage">
    <LoaderIcon />
  </section>
</template>

<script setup lang="ts">
import LoaderIcon from "~/components/loader-icon.vue";
</script>

<style module>
.loaderPage {
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
