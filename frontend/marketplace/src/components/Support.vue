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
          v-for="customer in telegramCustomers"
          :key="customer.id"
          icon="telegramFilled"
          size="md"
          type="neutral"
          :class="$style.customer"
          :active="customerId === customer.id"
          @click="setChat('TelegramCustomer', customer.id)"
        >
          Чат №{{ customer.id }}
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
import { showChat, telegramCustomers } from "~/composables/customerMessages";

defineOptions({ components: { TelegramCustomer } });

const customerId = ref<number>();
const activeChat = ref<"TelegramCustomer">();

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
  grid-template-columns: 320px 1fr;
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
  border-top-right-radius: 0%;
  border-bottom-right-radius: 0%;
  min-height: calc(100vh - 200px);
  border-top-color: transparent;
  border-left-color: transparent;
  border-bottom-color: transparent;
}

.customer {
  height: max-content;
  padding: 8px;
}
</style>
