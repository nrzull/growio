<template>
  <div :class="$style.main">
    <div id="main"></div>
    <div :class="$style.content">
      <RouterView v-if="isMounted" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";

const isMounted = ref(false);
onMounted(() => (isMounted.value = true));
</script>

<style module>
.main {
  height: 100%;
  overflow-y: auto;
  overflow-x: clip;
}

.content {
  position: relative;
  display: flex;
  flex-flow: column;
  gap: 20px;
  padding: 20px;
  height: inherit;
  max-width: 960px;
  width: 100%;
  margin: 0 auto;
}

:global(#main) {
  position: absolute;
  height: calc(100% - 40px);
  width: calc(100% - 40px);
  z-index: -1;
}
</style>
