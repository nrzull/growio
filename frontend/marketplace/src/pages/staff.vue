<template>
  <teleport to="#top-navigation">
    <RouterLink to="/staff/users" custom v-slot="{ navigate, isActive }">
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Users
      </Button>
    </RouterLink>

    <RouterLink to="/staff/roles" custom v-slot="{ navigate, isActive }">
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Roles
      </Button>
    </RouterLink>
  </teleport>

  <RouterView />
</template>

<script setup lang="ts">
import Button from "~/components/Button.vue";
</script>
