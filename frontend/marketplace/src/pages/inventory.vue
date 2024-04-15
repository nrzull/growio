<template>
  <teleport to="#top-navigation">
    <RouterLink v-slot="{ navigate, isActive }" to="/inventory/items" custom>
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Items
      </Button>
    </RouterLink>

    <RouterLink
      v-slot="{ navigate, isActive }"
      to="/inventory/categories"
      custom
    >
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Categories
      </Button>
    </RouterLink>

    <RouterLink
      v-slot="{ navigate, isActive }"
      to="/inventory/warehouses"
      custom
    >
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Warehouses
      </Button>
    </RouterLink>
  </teleport>

  <RouterView />
</template>

<script setup lang="ts">
import Button from "~/components/Button.vue";
</script>
