<template>
  <teleport to="#top-navigation">
    <RouterLink to="/inventory/items" custom v-slot="{ navigate, isActive }">
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Items
      </Button>
    </RouterLink>

    <RouterLink
      to="/inventory/categories"
      custom
      v-slot="{ navigate, isActive }"
    >
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Categories
      </Button>
    </RouterLink>
  </teleport>

  <RouterView />
</template>

<script setup lang="ts">
import Button from "~/components/Button.vue";
</script>
