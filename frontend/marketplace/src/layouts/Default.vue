<template>
  <Support />

  <div :class="$style.default">
    <Top :class="$style.top" />
    <Sidebar :class="$style.sidebar" />
    <div :class="$style.main">
      <div id="main"></div>
      <RouterView v-if="isMounted" />
    </div>
  </div>
</template>

<script setup lang="ts">
import Top from "~/layouts/Default/Top.vue";
import Sidebar from "~/layouts/Default/Sidebar.vue";
import { onMounted, ref } from "vue";
import { useCustomerMessages } from "~/composables/customerMessages";
import Support from "~/components/Support.vue";

const isMounted = ref(false);

useCustomerMessages();
onMounted(() => (isMounted.value = true));
</script>

<style module>
.default {
  display: grid;
  grid-template-areas: "sidebar top" "sidebar main";
  grid-template-columns: max-content 1fr;
  grid-template-rows: 60px auto;
  height: 100%;
}

.top {
  grid-area: top;
}

.sidebar {
  grid-area: sidebar;
}

.main {
  position: relative;
  display: flex;
  flex-flow: column;
  gap: 20px;
  grid-area: main;
  padding: 20px;
  height: 100%;
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
