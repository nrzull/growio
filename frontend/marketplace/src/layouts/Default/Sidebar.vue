<template>
  <div :class="$style.sidebar">
    <RouterLink
      v-for="{ icon, text, to } in buttons"
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
  </div>
</template>

<script setup>
import Icon from "~/components/Icon.vue";
import Button from "~/components/Button.vue";

const buttons = [
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
    icon: "settings01",
    text: "Settings",
    to: "/settings",
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
