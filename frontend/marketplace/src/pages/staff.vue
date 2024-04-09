<template>
  <teleport to="#top-navigation">
    <RouterLink to="/staff/users" custom v-slot="{ navigate }">
      <Button type="neutral" size="sm" @click="navigate">Users</Button>
    </RouterLink>

    <RouterLink to="/staff/roles" custom v-slot="{ navigate }">
      <Button type="neutral" size="sm" @click="navigate">Roles</Button>
    </RouterLink>
  </teleport>

  <RouterView />
</template>

<script setup lang="ts">
import Button from "~/components/Button.vue";
</script>
