<template>
  <div :class="$style.customerId">
    <div :class="$style.chat"></div>

    <div :class="$style.inputWrapper">
      <TextInput
        :inner-input-class="$style.input"
        placeholder="Message"
        @keydown.enter="sendMessage"
        v-model="input"
      />

      <Button
        type="link-neutral"
        :class="$style.send"
        icon="telegramFilled"
        size="md"
        @click="sendMessage"
      >
        Send
      </Button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import Button from "@growio/shared/components/Button.vue";
import { apiMarketplaceTelegramBotCustomerMessagesCreate } from "@growio/shared/api/growio/marketplace_telegram_bot_customer_messages";
import { useRoute } from "vue-router";

const route = useRoute();
const customerId = computed(() => Number(route.params.customerId));
const input = ref<string>();

const sendMessage = () => {
  if (!input.value) {
    return;
  }

  const text = input.value;

  apiMarketplaceTelegramBotCustomerMessagesCreate({
    customer_id: customerId.value,
    text,
  }).then(() => (input.value === text ? (input.value = undefined) : null));
};
</script>

<style module>
.customerId {
  display: flex;
  flex-flow: column;
  justify-content: space-between;
  height: 100%;
}

.chat {
  height: calc(100vh - 400px);
  overflow: auto;
}

.inputWrapper {
  position: relative;
}

.input {
  padding-right: 100px;
}

.send {
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  z-index: 1000;
}

.send svg {
  color: var(--color-gray-500);
}
</style>
