<template>
  <div :class="$style.top">
    <div></div>
    <div></div>
    <div>{{ marketplaceAccount?.marketplace?.name }}</div>
  </div>
</template>

<script setup lang="ts">
import { marketplaceAccount } from "~/composables/marketplace-accounts";
</script>

<style module>
.top {
  background-color: var(--color-white);
  border-bottom: 1px solid var(--color-gray-100);
  display: flex;
  align-items: center;
  padding: 0 20px;
  justify-content: space-between;
}
</style>
