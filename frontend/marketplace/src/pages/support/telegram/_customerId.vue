<template>
  <div :class="$style.customerId">
    <div :class="$style.chat"></div>

    <div :class="$style.actions">
      <TextInput placeholder="Message" />
      <Button>Send</Button>
    </div>
  </div>
</template>

<script setup lang="ts">
import TextInput from "@growio/shared/components/TextInput.vue";
import Button from "@growio/shared/components/Button.vue";
</script>

<style module>
.customerId {
  display: flex;
  flex-flow: column;
  justify-content: space-between;
}

.chat {
  height: calc(100vh - 400px);
  overflow: auto;
}

.actions {
  gap: 12px;
  display: grid;
}
</style>
