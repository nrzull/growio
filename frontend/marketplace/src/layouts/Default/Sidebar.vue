<template>
  <div :class="$style.sidebar">
    <RouterLink
      v-for="{ icon, text, to } in buttons"
      :key="text"
      v-slot="{ isActive, navigate }"
      custom
      :to="to"
    >
      <div
        :class="[$style.button, { [$style.active]: isActive }]"
        @click="navigate"
      >
        <div :class="$style.icon" v-html="icon"></div>
        <div :class="$style.text">{{ text }}</div>
      </div>
    </RouterLink>
  </div>
</template>

<script setup>
import usersSvg from "~/assets/users.svg?raw";
import crownLineSvg from "~/assets/crown-line.svg?raw";
import adProductSvg from "~/assets/ad-product.svg?raw";

const buttons = [
  {
    icon: usersSvg,
    text: "Users",
    to: "/users",
  },

  {
    icon: crownLineSvg,
    text: "Roles",
    to: "/roles",
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
  gap: 24px;
  overflow-x: clip;
  overflow-y: auto;
}

.button {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 8px;

  user-select: none;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 8px;
  width: 100%;
}

.text {
  font-size: 14px;
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
