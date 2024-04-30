<template>
  <PageLoader :loading="isLoading" />

  <PageShape>
    <template #heading>Support</template>

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
          @click="$router.push(`/support/telegram/${customer.id}`)"
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

      <RouterView v-else :key="customerId" />
    </div>
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { apiMarketplaceTelegramBotCustomersGetAll } from "@growio/shared/api/growio/marketplace_telegram_bot_customers";
import { MarketplaceTelegramBotCustomer } from "@growio/shared/api/growio/marketplace_telegram_bot_customers/types";
import { wait, Wait } from "@growio/shared/composables/wait";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import { useRoute } from "vue-router";
import Button from "@growio/shared/components/Button.vue";
import Shape from "@growio/shared/components/Shape.vue";

const route = useRoute();
const customerId = computed(() => Number(route.params.customerId));

const telegramCustomers = ref<MarketplaceTelegramBotCustomer[]>([]);

const isLoading = computed(() =>
  wait.some([Wait.MARKETPLACE_TELEGRAM_BOT_CUSTOMERS_FETCH])
);

const fetchCustomers = async () => {
  try {
    wait.start(Wait.MARKETPLACE_TELEGRAM_BOT_CUSTOMERS_FETCH);

    telegramCustomers.value = await apiMarketplaceTelegramBotCustomersGetAll({
      filters: { conversation: true },
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_TELEGRAM_BOT_CUSTOMERS_FETCH);
  }
};

fetchCustomers();
</script>

<style module>
.support {
  display: grid;
  grid-template-columns: 320px 1fr;
  height: 100%;
  gap: 12px;
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
  display: grid;
  padding: 8px;
}

.customer {
  height: max-content;
}
</style>
