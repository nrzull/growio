<template>
  <div :class="$style.main">
    <div id="main"></div>
    <RouterView v-if="isMounted" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";

const isMounted = ref(false);
onMounted(() => (isMounted.value = true));
</script>

<style module>
.main {
  position: relative;
  display: flex;
  flex-flow: column;
  gap: 20px;
  padding: 20px;
  height: 100%;
  max-width: 960px;
  width: 100%;
  margin: 0 auto;
  overflow-y: auto;
  overflow-x: clip;
}

:global(#main) {
  position: absolute;
  height: calc(100% - 40px);
  width: calc(100% - 40px);
  z-index: -1;
}
</style>
