import { apiCustomersGetMarketplacePayload } from "@growio/shared/api/growio/customers";
import { MarketplacePayload } from "@growio/shared/api/growio/customers/types";
import { Wait, wait } from "@growio/shared/composables/wait";
import { ref } from "vue";

export const payload = ref<MarketplacePayload>();

export const fetchPayload = async (payloadKey: string) => {
  payload.value = await getPayload(payloadKey);

  if (payload.value) {
    document.title = payload.value.marketplace.name;
  }
};

export const getPayload = async (payloadKey: string) => {
  try {
    wait.start(Wait.MARKETPLACE_PAYLOAD_FETCH);
    return apiCustomersGetMarketplacePayload(payloadKey);
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_PAYLOAD_FETCH);
  }
};
