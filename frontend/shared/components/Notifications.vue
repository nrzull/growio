<template>
  <div :class="$style.notifications">
    <Notification
      v-for="notification in state"
      :key="notification.id"
      :model-value="notification"
    />
  </div>
</template>

<script setup lang="ts">
import { state } from "@growio/shared/composables/notifications";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
</script>

<style module>
.notifications {
  position: fixed;
  right: var(--notifications-right);
  top: var(--notifications-top);
  z-index: var(--z-index-notifications);
  display: grid;
  gap: 8px;
}
</style>
