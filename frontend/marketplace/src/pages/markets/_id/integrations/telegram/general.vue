<template>
  <PageShape>
    <template #heading>
      <slot name="tabs"></slot>
    </template>

    <div :class="$style.body">
      <div :class="$style.grid">
        <div :class="$style.row">
          <TextInput placeholder="Name" />
          <TextInput placeholder="Description" />
        </div>

        <div :class="$style.row">
          <TextInput placeholder="Welcome message" />
        </div>
      </div>

      <Button :disabled="isLoading">Save</Button>
    </div>
  </PageShape>
</template>

<script setup lang="ts">
import { computed } from "vue";
import PageShape from "~/components/PageShape.vue";
import Button from "~/components/Button.vue";
import { wait } from "~/composables/wait";
import TextInput from "~/components/TextInput.vue";

const isLoading = computed(() => wait.some([]));
</script>

<style module>
.row {
  display: flex;
  gap: 8px;
}

.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}

.body {
  display: flex;
  flex-flow: column;
  justify-content: space-between;
  height: 100%;
  gap: 24px;
}
</style>
