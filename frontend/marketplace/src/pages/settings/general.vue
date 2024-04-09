<template>
  <PageLoader :loading="isLoading" />

  <PageShape>
    <template #heading> General </template>
  </PageShape>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { wait } from "~/composables/wait";
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";

const isLoading = computed(() => wait.some([]));
</script>
