<template>
  {{ order_id }}
</template>

<script setup lang="ts">
const url = new URL(document.location.href);
const order_id = url.searchParams.get("order_id");
</script>
