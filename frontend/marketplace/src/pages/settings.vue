<template>
  <teleport to="#top-navigation">
    <RouterLink to="/settings/general" custom v-slot="{ navigate, isActive }">
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        General
      </Button>
    </RouterLink>

    <RouterLink
      to="/settings/subscription"
      custom
      v-slot="{ navigate, isActive }"
    >
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        Subscription
      </Button>
    </RouterLink>
  </teleport>

  <RouterView />
</template>

<script setup lang="ts">
import Button from "~/components/Button.vue";
</script>
