<template>
  <teleport to="#top-navigation">
    <RouterLink to="/inventory/items" custom v-slot="{ navigate }">
      <Button type="neutral" size="sm" @click="navigate">Items</Button>
    </RouterLink>

    <RouterLink to="/inventory/categories" custom v-slot="{ navigate }">
      <Button type="neutral" size="sm" @click="navigate">Categories</Button>
    </RouterLink>
  </teleport>

  <RouterView />
</template>

<script setup lang="ts">
import Button from "~/components/Button.vue";
</script>
