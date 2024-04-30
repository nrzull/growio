import { onBeforeUnmount, onMounted, ref } from "vue";
import { growioWS } from "@growio/shared/api/growio";
import { marketplaceAccount } from "~/composables/marketplace-accounts";
import { apiAuthHealthcheck } from "@growio/shared/api/growio/auth";

export const useCustomerMessagesChannel = () => {
  const channel = ref(growioWS.channel("customer:messages"));

  const messageHandle = channel.value.on("message", (payload) => {
    console.log(payload);
  });

  onMounted(async () => {
    if (!growioWS.isConnected()) {
      const { ws_token } = await apiAuthHealthcheck();
      growioWS.connect({ ws_token });
    }

    channel.value.join();
  });

  onBeforeUnmount(() => {
    channel.value.off("message", messageHandle);
    channel.value.leave();
  });

  return { channel };
};
