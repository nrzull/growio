<template>
  <div :class="$style.customerId">
    <div :class="$style.chat">
      <div
        v-for="message in activeMessages"
        :key="message.id"
        :class="[
          $style.message,
          { [$style.customer]: !message.marketplace_account_id },
        ]"
      >
        {{ message.text }}
      </div>
    </div>

    <div :class="$style.inputWrapper">
      <TextInput
        v-model="input"
        :inner-input-class="$style.input"
        placeholder="Message"
        @keydown.enter="sendMessage"
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
import { customerMessages } from "~/composables/customerMessages";
import { compareDesc } from "date-fns";

const input = ref<string>();

const props = defineProps({
  customerId: {
    type: Number,
    required: true,
  },
});

const activeMessages = computed(() =>
  customerMessages.value
    .filter((v) => v.customer_id === props.customerId)
    .sort((a1, a2) =>
      compareDesc(new Date(a1.inserted_at), new Date(a2.inserted_at))
    )
);

const sendMessage = () => {
  if (!input.value) {
    return;
  }

  const text = input.value;

  apiMarketplaceTelegramBotCustomerMessagesCreate({
    customer_id: props.customerId,
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
  height: calc(100vh - 300px);
  overflow: auto;
  display: flex;
  flex-flow: column-reverse;
  gap: 8px;
  margin-bottom: 24px;
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

.message {
  display: flex;
  height: max-content;
  width: max-content;
  padding: 8px 16px;
  background-color: var(--color-gray-50);
  border-radius: 16px;
}

.message.customer {
  background-color: var(--color-primary);
}
</style>
