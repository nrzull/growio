<template>
  <div :class="[$style.notificationItem, $style[modelValue.type]]">
    {{ modelValue.text }}
  </div>
</template>

<script setup lang="ts">
import { PropType } from "vue";
import type { NotificationItem } from "~/composables/notifications";

defineProps({
  modelValue: {
    type: Object as PropType<Pick<NotificationItem, "type" | "text">>,
    required: true,
  },
});
</script>

<style module>
.notificationItem {
  padding: 18px;
  border-radius: 8px;
  border: 1px solid var(--color-gray-100);
  background-color: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(16px);
  color: #111;
  display: flex;
  gap: 18px;
  align-items: center;
  font-size: 13px;
  font-weight: 500;
  line-height: 1.1;
  width: 100%;
}

.notificationItem.success svg:has(path[fill]) * {
  --icon-color: hsl(130, 40%, 60%);
  fill: var(--icon-color);
}

.notificationItem.success svg:has(path[stroke]) * {
  --icon-color: hsl(130, 40%, 60%);
  stroke: var(--icon-color);
}

.notificationItem.warning svg:has(path[fill]) * {
  --icon-color: hsl(130, 40%, 60%);
  fill: var(--icon-color);
}

.notificationItem.warning svg:has(path[stroke]) * {
  --icon-color: hsl(130, 40%, 60%);
  stroke: var(--icon-color);
}

.notificationItem.error svg:has(path[fill]) * {
  --icon-color: hsl(130, 40%, 60%);
  fill: var(--icon-color);
}

.notificationItem.error svg:has(path[stroke]) * {
  --icon-color: hsl(130, 40%, 60%);
  stroke: var(--icon-color);
}

.notificationItem.info svg:has(path[fill]) * {
  --icon-color: hsl(130, 40%, 60%);
  fill: var(--icon-color);
}

.notificationItem.info svg:has(path[stroke]) * {
  --icon-color: hsl(130, 40%, 60%);
  stroke: var(--icon-color);
}

.icon {
  width: 24px;
  min-width: 24px;
}
</style>
