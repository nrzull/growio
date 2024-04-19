<template>
  <PageShape>
    <template #heading>
      <slot name="tabs"></slot>
    </template>
  </PageShape>
</template>

<script setup lang="ts">
import PageShape from "~/components/PageShape.vue";
</script>
