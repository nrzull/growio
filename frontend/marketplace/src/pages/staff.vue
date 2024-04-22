<template>
  <teleport to="#top-navigation">
    <RouterLink v-slot="{ navigate, isActive }" to="/staff/users" custom>
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Users
      </Button>
    </RouterLink>

    <RouterLink v-slot="{ navigate, isActive }" to="/staff/roles" custom>
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Roles
      </Button>
    </RouterLink>
  </teleport>

  <RouterView />
</template>

<script setup lang="ts">
import Button from "@growio/shared/components/Button.vue";
</script>
