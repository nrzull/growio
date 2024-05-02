import { onBeforeUnmount, onMounted, ref, computed } from "vue";
import { growioWS } from "@growio/shared/api/growio";
import { apiAuthHealthcheck } from "@growio/shared/api/growio/auth";
import { MarketplaceTelegramBotCustomerMessage } from "@growio/shared/api/growio/marketplace_telegram_bot_customer_messages/types";

export const customerMessages = ref<MarketplaceTelegramBotCustomerMessage[]>(
  []
);

export const unreadMessagesCount = computed(
  () => customerMessages.value.filter((v) => !v.read).length
);

export const showChat = ref(false);

export const useCustomerMessages = () => {
  const channel = ref(growioWS.channel("customer:messages"));

  const messageHandle = channel.value.on(
    "new_message",
    (payload: MarketplaceTelegramBotCustomerMessage) => {
      customerMessages.value.push(payload);
    }
  );

  onMounted(async () => {
    if (!growioWS.isConnected()) {
      const { ws_token } = await apiAuthHealthcheck();
      growioWS.connect({ ws_token });
    }

    channel.value.join();
  });

  onBeforeUnmount(() => {
    channel.value.off("new_message", messageHandle);
    channel.value.leave();
  });

  return { channel };
};
