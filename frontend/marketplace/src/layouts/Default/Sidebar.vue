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
        <div :class="$style.icon" v-html="icon"></div>
        <div>{{ text }}</div>
      </Button>
    </RouterLink>
  </div>
</template>

<script setup>
import usersSvg from "~/assets/users.svg?raw";
import adProductSvg from "~/assets/ad-product.svg?raw";
import Button from "~/components/Button.vue";

const buttons = [
  {
    icon: usersSvg,
    text: "Staff",
    to: "/staff",
  },

  {
    icon: adProductSvg,
    text: "Inventory",
    to: "/inventory",
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
