<template>
  <div :class="$style.top">
    <div id="top-navigation" :class="$style.navigation"></div>

    <Menu
      :items="items"
      track-by="text"
      label-path="text"
      @click:item="$event.action?.()"
    >
      <div :class="$style.profile">
        <div>{{ marketplaceAccount?.marketplace?.name }}</div>
        <Tag>{{ marketplaceAccount?.role?.name }}</Tag>
      </div>
    </Menu>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { marketplaceAccount } from "~/composables/marketplace-accounts";
import Menu from "@growio/shared/components/Menu.vue";
import Tag from "@growio/shared/components/Tag.vue";
import { useRouter } from "vue-router";

const router = useRouter();

const items = ref([
  {
    text: "Marketplaces",
    action: () => router.push("/self/marketplaces"),
  },

  {
    text: "Sign-Out",
    action: () => router.push("/auth"),
  },
]);
</script>

<style module>
.top {
  background-color: var(--color-white);
  border-bottom: 1px solid var(--color-gray-100);
  display: flex;
  align-items: center;
  padding: 0 20px;
  justify-content: space-between;
}

.navigation {
  display: flex;
  gap: 8px;
}

.profile {
  display: inline-flex;
  gap: 8px;
  user-select: none;
  align-items: center;
}
</style>
