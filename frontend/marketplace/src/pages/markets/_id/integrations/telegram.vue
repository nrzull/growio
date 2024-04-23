<template>
  <TelegramBotModal
    v-if="telegramBotModal"
    :model-value="telegramBotModal"
    :loading="isLoading"
    @close="telegramBotModal = undefined"
    @submit="updateTelegramBot"
  />

  <RouterView v-slot="{ Component }">
    <component :is="Component" v-if="telegramBot" v-bind="$props">
      <template #tabs>
        <Tabs>
          <RouterLink
            v-slot="{ navigate }"
            :to="`/markets/${market.id}/integrations`"
            custom
          >
            <Button type="neutral" size="md" icon="arrowBack" @click="navigate">
              {{ market.address }}
            </Button>
          </RouterLink>

          <Button
            type="neutral"
            size="md"
            icon="editRegular"
            :active="!!telegramBotModal"
            @click="telegramBotModal = telegramBot"
          >
            Telegram Bot
          </Button>

          <RouterLink
            v-slot="{ navigate, isActive }"
            :to="`/markets/${market.id}/integrations/telegram/mailing`"
            custom
          >
            <Button
              type="neutral"
              size="md"
              :active="isActive"
              @click="navigate"
            >
              Mailing
            </Button>
          </RouterLink>
        </Tabs>
      </template>
    </component>
  </RouterView>
</template>

<script setup lang="ts">
import { PropType, ref, computed } from "vue";
import { MarketplaceMarket } from "@growio/shared/api/growio/marketplace_markets/types";
import Button from "@growio/shared/components/Button.vue";
import Tabs from "@growio/shared/components/Tabs.vue";
import TelegramBotModal from "~/components/Market/Integrations/TelegramBotModal.vue";
import {
  apiMarketplaceMarketTelegramBotGetSelf,
  apiMarketplaceMarketTelegramBotUpdateSelf,
} from "@growio/shared/api/growio/marketplace_market_telegram_bots";
import { MarketplaceMarketTelegramBot } from "@growio/shared/api/growio/marketplace_market_telegram_bots/types";
import { wait, Wait } from "@growio/shared/composables/wait";

const props = defineProps({
  market: {
    type: Object as PropType<MarketplaceMarket>,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const telegramBot = ref<MarketplaceMarketTelegramBot>();
const telegramBotModal = ref<MarketplaceMarketTelegramBot>();

const isLoading = computed(
  () =>
    props.loading ||
    wait.some([
      Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_FETCH,
      Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_UPDATE,
    ])
);

const updateTelegramBot = async (params: MarketplaceMarketTelegramBot) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_UPDATE);
    await apiMarketplaceMarketTelegramBotUpdateSelf(params);
    await fetchTelegramBot();
    telegramBotModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_UPDATE);
  }
};

const fetchTelegramBot = async () => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_FETCH);
    telegramBot.value = await apiMarketplaceMarketTelegramBotGetSelf({
      market_id: props.market.id,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_FETCH);
  }
};

fetchTelegramBot();
</script>
