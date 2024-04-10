<template>
  <teleport to="#top-navigation">
    <RouterLink v-slot="{ navigate, isActive }" to="/settings/general" custom>
      <Button type="neutral" size="sm" :active="isActive" @click="navigate">
        General
      </Button>
    </RouterLink>

    <RouterLink
      v-slot="{ navigate, isActive }"
      to="/settings/subscription"
      custom
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
