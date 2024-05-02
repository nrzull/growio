import { onBeforeUnmount, onMounted, ref } from "vue";
import { growioWS } from "@growio/shared/api/growio";
import { apiAuthHealthcheck } from "@growio/shared/api/growio/auth";
import { MarketplaceTelegramBotCustomerMessage } from "@growio/shared/api/growio/marketplace_telegram_bot_customer_messages/types";

export const customerMessages = ref<MarketplaceTelegramBotCustomerMessage[]>(
  []
);

export const useCustomerMessagesChannel = () => {
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
