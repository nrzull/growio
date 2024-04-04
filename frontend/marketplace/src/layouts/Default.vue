<template>
  <div :class="$style.default">
    <Top :class="$style.top" />
    <Sidebar :class="$style.sidebar" />
    <div :class="$style.main">
      <RouterView />
    </div>
  </div>
</template>

<script setup lang="ts">
import Top from "~/layouts/Default/Top.vue";
import Sidebar from "~/layouts/Default/Sidebar.vue";
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
  grid-area: main;
  padding: 20px;
}
</style>
