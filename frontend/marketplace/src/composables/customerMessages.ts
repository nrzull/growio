import { onBeforeUnmount, onMounted, ref, computed } from "vue";
import { growioWS } from "@growio/shared/api/growio";
import { apiAuthHealthcheck } from "@growio/shared/api/growio/auth";
import { MarketplaceTelegramBotCustomerMessage } from "@growio/shared/api/growio/marketplace_telegram_bot_customer_messages/types";
import { Wait, wait } from "@growio/shared/composables/wait";
import {
  apiMarketplaceTelegramBotCustomersGetAll,
  apiMarketplaceTelegramBotCustomersGetOne,
} from "@growio/shared/api/growio/marketplace_telegram_bot_customers";
import { MarketplaceTelegramBotCustomer } from "@growio/shared/api/growio/marketplace_telegram_bot_customers/types";
import { apiMarketplaceTelegramBotCustomerMessagesGetAll } from "@growio/shared/api/growio/marketplace_telegram_bot_customer_messages";

export const showChat = ref(false);

export const telegramCustomers = ref<MarketplaceTelegramBotCustomer[]>([]);

export const customerMessages = ref<
  Map<MarketplaceTelegramBotCustomer, MarketplaceTelegramBotCustomerMessage[]>
>(new Map());

export const unreadMessagesCount = computed(() =>
  Array.from(customerMessages.value.values()).reduce(
    (acc, v) => acc + v.filter((vv) => !vv.read).length,
    0
  )
);

export const unreadMessagesCountByCustomer = (
  customer: MarketplaceTelegramBotCustomer
) => customerMessages.value.get(customer)?.filter((v) => !v.read).length || 0;

const fetchTelegramCustomers = async () => {
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

const fetchTelegramCustomerMessages = async (
  customer: MarketplaceTelegramBotCustomer
) => {
  try {
    const messages = await apiMarketplaceTelegramBotCustomerMessagesGetAll({
      customer_id: customer.id,
    });

    if (!customerMessages.value.has(customer)) {
      customerMessages.value.set(customer, []);
    }

    customerMessages.value.get(customer).push(...messages);
  } catch (e) {
    console.error(e);
  }
};

export const useCustomerMessages = () => {
  const channel = ref(growioWS.channel("customer:messages"));

  const messageHandle = channel.value.on(
    "new_message",
    async (payload: MarketplaceTelegramBotCustomerMessage) => {
      const customer =
        telegramCustomers.value.find((v) => v.id === payload.customer_id) ||
        (await apiMarketplaceTelegramBotCustomersGetOne({
          customer_id: payload.customer_id,
          filters: { conversation: true },
        }));

      if (!customerMessages.value.has(customer)) {
        customerMessages.value.set(customer, []);
      }

      customerMessages.value.get(customer).push(payload);
    }
  );

  onMounted(async () => {
    if (!growioWS.isConnected()) {
      const { ws_token } = await apiAuthHealthcheck();
      growioWS.connect({ ws_token });
    }

    channel.value.join();

    await fetchTelegramCustomers();

    for (const customer of telegramCustomers.value) {
      await fetchTelegramCustomerMessages(customer);
    }
  });

  onBeforeUnmount(() => {
    channel.value.off("new_message", messageHandle);
    channel.value.leave();
  });

  return { channel };
};
