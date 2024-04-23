<template>
  <PageShape>
    <template #heading>
      <slot name="tabs"></slot>
    </template>
  </PageShape>
</template>

<script setup lang="ts">
import PageShape from "@growio/shared/components/PageShape.vue";
</script>
