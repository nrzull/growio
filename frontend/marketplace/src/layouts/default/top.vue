<template>
  <div :class="$style.top">
    <div></div>
    <div></div>

    <Menu :items="items" @click:item="$event?.action?.()">
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
import Menu from "~/components/menu.vue";
import Tag from "~/components/tag.vue";
import { useRouter } from "vue-router";

const router = useRouter();

const items = ref([
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

.profile {
  display: inline-flex;
  gap: 8px;
  user-select: none;
  align-items: center;
}
</style>
