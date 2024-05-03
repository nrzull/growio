<template>
  <div :class="$style.customerId">
    <div ref="chatRef" :class="$style.chat">
      <div
        v-for="(messages, key) in activeMessagesByGroups"
        :class="$style.chatFrame"
        :key="key"
      >
        <div :class="$style.dateSeparator">
          <Tag size="md">{{ formatRelative(new Date(key as string)) }}</Tag>
        </div>

        <div
          v-for="message in messages"
          :key="message.id"
          :class="[
            $style.message,
            { [$style.customer]: !message.marketplace_account_id },
          ]"
        >
          <div :class="$style.text">{{ message.text }}</div>
          <div :class="$style.datetime">
            {{ formatHHMM(new Date(message.inserted_at)) }}
          </div>
        </div>
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
import { computed, onMounted, ref, watch } from "vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import Button from "@growio/shared/components/Button.vue";
import { apiMarketplaceTelegramBotCustomerMessagesCreate } from "@growio/shared/api/growio/marketplace_telegram_bot_customer_messages";
import {
  customerMessages,
  telegramCustomers,
} from "~/composables/customerMessages";
import { compareAsc } from "date-fns";
import {
  formatHHMM,
  formatDDMMYY,
  formatRelative,
} from "@growio/shared/utils/datetime";
import { groupBy } from "remeda";
import Tag from "@growio/shared/components/Tag.vue";

const input = ref<string>();
const chatRef = ref<HTMLDivElement>();

const props = defineProps({
  customerId: {
    type: Number,
    required: true,
  },
});

const customer = computed(
  () => telegramCustomers.value.find((v) => v.id === props.customerId)!
);

const activeMessages = computed(
  () =>
    customerMessages.value
      .get(customer.value)
      ?.slice()
      .sort((a1, a2) =>
        compareAsc(new Date(a1.inserted_at), new Date(a2.inserted_at))
      ) || []
);

const activeMessagesByGroups = computed(() =>
  groupBy(activeMessages.value, (item) =>
    formatDDMMYY(new Date(item.inserted_at))
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

const scrollToBottom = () => {
  chatRef.value?.scrollTo({
    top: chatRef.value.scrollHeight,
    behavior: "instant",
  });
};

onMounted(scrollToBottom);

watch(
  () => activeMessages.value?.length,
  (v, oldV) => {
    if (v > oldV) {
      scrollToBottom();
    }
  },
  { flush: "post" }
);
</script>

<style module>
.customerId {
  display: flex;
  flex-flow: column;
  justify-content: space-between;
  height: 100%;
  padding: 12px;
}

.chat {
  height: calc(100vh - 300px);
  overflow-y: auto;
  overflow-x: hidden;
  margin-bottom: 24px;
}

.chatFrame {
  display: flex;
  flex-flow: column;
  gap: 8px;
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
  display: inline-flex;
  width: fit-content;
  max-width: 75%;
  padding: 8px 12px;
  background-color: var(--color-gray-50);
  border-radius: 6px 24px 24px 6px;
  align-items: flex-end;
  justify-content: space-between;
  gap: 8px;
}

.message.customer {
  background-color: var(--color-primary);
}

.dateSeparator {
  text-align: center;
  position: sticky;
  top: 0;
}

.datetime {
  font-size: 10px;
  font-weight: 500;
  color: var(--color-gray-500);
}

.message.customer .datetime {
  color: var(--color-primary-800);
}

.text {
  overflow-wrap: anywhere;
}
</style>
