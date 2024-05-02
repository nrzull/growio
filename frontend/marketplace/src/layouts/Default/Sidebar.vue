<template>
  <div :class="$style.sidebar">
    <template v-for="{ icon, text, to, action, badge } in buttons">
      <RouterLink
        v-if="to"
        :key="text"
        v-slot="{ isActive, navigate }"
        custom
        :to="to"
      >
        <Button
          :class="$style.button"
          type="neutral"
          size="md"
          :active="isActive"
          @click="navigate"
        >
          <Icon :class="$style.icon" :value="icon" />
          <div>{{ text }}</div>
        </Button>
      </RouterLink>
      <Button
        v-else
        :key="`btn-${text}`"
        :class="$style.button"
        type="neutral"
        size="md"
        @click="action?.()"
      >
        <Icon :class="$style.icon" :value="icon" />
        <div>{{ text }}</div>
        <Badge :model-value="badge?.value" />
      </Button>
    </template>
  </div>
</template>

<script setup lang="ts">
import Icon, { Icons } from "@growio/shared/components/Icon.vue";
import Button from "@growio/shared/components/Button.vue";
import { showChat } from "~/composables/customerMessages";
import Badge from "@growio/shared/components/Badge.vue";
import { unreadMessagesCount } from "~/composables/customerMessages";
import { Ref, ComputedRef } from "vue";

const buttons: Array<{
  icon: Icons;
  text: string;
  to?: string;
  action?: () => void;
  badge?: Ref | ComputedRef<number>;
}> = [
  {
    icon: "users",
    text: "Staff",
    to: "/staff",
  },

  {
    icon: "adProduct",
    text: "Inventory",
    to: "/inventory",
  },

  {
    icon: "order",
    text: "Orders",
    to: "/orders",
  },

  {
    icon: "support",
    text: "Support",
    action: () => (showChat.value = true),
    badge: unreadMessagesCount,
  },

  {
    icon: "settings01",
    text: "Settings",
    to: "/settings",
  },

  {
    icon: "analytics",
    text: "Stats",
    to: "/stats",
  },
];
</script>

<style module>
.sidebar {
  background-color: var(--color-white);
  border-right: 1px solid var(--color-gray-100);
  padding: 20px;
  display: flex;
  flex-flow: column;
  align-items: center;
  gap: 8px;
  overflow-x: clip;
  overflow-y: auto;
}

.button {
  justify-content: flex-start;
  width: 100%;
}

.button.active {
  background-color: var(--color-gray-100);
}

.icon {
  display: inline-flex;
}

.icon svg {
  width: 24px;
  min-width: 24px;
}
</style>
