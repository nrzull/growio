<template>
  <Modal
    v-if="showChat"
    size="lg"
    :shape-props="{ paddingless: true }"
    :loading="isLoading"
    @close="showChat = false"
  >
    <div
      :class="[$style.support, { [$style.empty]: !telegramCustomers.length }]"
    >
      <Shape
        v-if="telegramCustomers.length"
        type="secondary"
        :class="$style.customers"
      >
        <Button
          v-for="customer in sortedTelegramCustomers"
          :key="customer.id"
          icon="telegramFilled"
          size="md"
          type="neutral"
          :class="$style.chatButton"
          :active="customerId === customer.id"
          @click="setChat('TelegramCustomer', customer.id)"
        >
          <div :class="$style.chatButtonInner">
            <div :class="$style.chatButtonTitle">
              <span>Чат №{{ customer.id }}</span>
              <span :class="$style.chatButtonDate">
                {{ formatHHMM(new Date(latestMessage(customer).inserted_at)) }}
              </span>
            </div>

            <div :class="$style.chatButtonMessage">
              <span :class="$style.chatButtonText">
                {{ latestMessage(customer).text }}
              </span>
              <Badge
                :class="$style.chatButtonBadge"
                :model-value="unreadMessagesCountByCustomer(customer)"
              ></Badge>
            </div>
          </div>
        </Button>
      </Shape>

      <div v-if="!telegramCustomers.length" :class="$style.notice">
        There is no active chats
      </div>
      <div v-else-if="!customerId" :class="$style.notice">
        Select a chat to start messaging
      </div>

      <component :is="activeChat" :key="customerId" :customer-id="customerId" />
    </div>
  </Modal>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { wait, Wait } from "@growio/shared/composables/wait";
import Button from "@growio/shared/components/Button.vue";
import Shape from "@growio/shared/components/Shape.vue";
import Modal from "@growio/shared/components/Modal.vue";
import TelegramCustomer from "~/components/Support/TelegramCustomer.vue";
import {
  showChat,
  telegramCustomers,
  unreadMessagesCountByCustomer,
  customerMessages,
} from "~/composables/customerMessages";
import Badge from "@growio/shared/components/Badge.vue";
import { compareDesc } from "date-fns";
import { MarketplaceTelegramBotCustomer } from "@growio/shared/api/growio/marketplace_telegram_bot_customers/types";
import { formatHHMM } from "@growio/shared/utils/datetime";

defineOptions({ components: { TelegramCustomer } });

const customerId = ref<number>();
const activeChat = ref<"TelegramCustomer">();

const sortedTelegramCustomers = computed(() =>
  telegramCustomers.value.slice().sort((c1, c2) => {
    const m1 = latestMessage(c1);
    const m2 = latestMessage(c2);
    return compareDesc(new Date(m1.inserted_at), new Date(m2.inserted_at));
  })
);

const latestMessage = (v: MarketplaceTelegramBotCustomer) =>
  customerMessages.value.get(v)?.at(-1);

const setChat = (component: "TelegramCustomer", id: number) => {
  customerId.value = id;
  activeChat.value = component;
};

const isLoading = computed(() =>
  wait.some([Wait.MARKETPLACE_TELEGRAM_BOT_CUSTOMERS_FETCH])
);
</script>

<style module>
.support {
  display: grid;
  grid-template-columns: 320px calc(100% - 320px);
  height: 100%;
  overflow: auto;
}

.support.empty {
  grid-template-columns: 1fr;
}

.notice {
  display: flex;
  flex-flow: column;
  justify-content: center;
  align-items: center;
  width: 100%;
}

.chat {
  display: flex;
  flex-flow: column;
  height: 100%;
  overflow: auto;
}

.customers {
  display: flex;
  flex-flow: column;
  padding: 8px;
  gap: 8px;
  border-top-right-radius: 0%;
  border-bottom-right-radius: 0%;
  min-height: calc(100vh - 200px);
  border-top-color: transparent;
  border-left-color: transparent;
  border-bottom-color: transparent;
}

.chatButtonInner {
  width: 100%;
  display: grid;
  gap: 4px;
}

.chatButtonTitle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.chatButtonDate {
  font-size: 10px;
  font-weight: 500;
  color: var(--color-gray-500);
}

.chatButtonMessage {
  display: flex;
  justify-content: space-between;
  width: 100%;
  overflow: hidden;
  gap: 8px;
}

.chatButtonText {
  color: var(--color-gray-500);
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
}
</style>
