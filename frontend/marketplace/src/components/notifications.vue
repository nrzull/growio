<template>
  <div :class="$style.notifications">
    <NotificationItem
      v-for="notification in state"
      :key="notification.id"
      :model-value="notification"
    />
  </div>
</template>

<script setup lang="ts">
import { defineProps } from "vue";
import { state } from "~/composables/notifications";
import NotificationItem from "~/components/notifications/item.vue";
</script>

<style module>
.notifications {
  position: fixed;
  right: 24px;
  top: calc(96px - 24px);
  z-index: var(--z-index-notifications);
  display: grid;
  gap: 8px;
}
</style>
