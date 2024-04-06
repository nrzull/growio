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
  border: 1px solid transparent;
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

.notificationItem.success {
  background-color: hsla(130, 50%, 60%, 10%);
  border-color: var(--color-green);
  color: hsla(130, 50%, 35%);
}

.notificationItem.info {
  background-color: hsla(0, 0%, 100%, 10%);
  border-color: var(--color-gray-100);
}

.notificationItem.error {
  background-color: hsla(0, 50%, 60%, 10%);
  border-color: var(--color-red);
  color: hsla(0, 50%, 50%);
}
</style>
