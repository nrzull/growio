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
          <RouterLink v-slot="{ navigate }" to="/settings/integrations" custom>
            <Button type="neutral" size="md" icon="arrowBack" @click="navigate">
              Integrations
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
            to="/settings/integrations/telegram/mailing"
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
import { ref, computed } from "vue";
import Button from "@growio/shared/components/Button.vue";
import Tabs from "@growio/shared/components/Tabs.vue";
import TelegramBotModal from "~/components/Integrations/TelegramBotModal.vue";
import {
  apiMarketplaceTelegramBotGetSelf,
  apiMarketplaceTelegramBotUpdateSelf,
} from "@growio/shared/api/growio/marketplace_telegram_bots";
import { MarketplaceTelegramBot } from "@growio/shared/api/growio/marketplace_telegram_bots/types";
import { wait, Wait } from "@growio/shared/composables/wait";

const props = defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
});

const telegramBot = ref<MarketplaceTelegramBot>();
const telegramBotModal = ref<MarketplaceTelegramBot>();

const isLoading = computed(
  () =>
    props.loading ||
    wait.some([
      Wait.MARKETPLACE_TELEGRAM_BOT_FETCH,
      Wait.MARKETPLACE_TELEGRAM_BOT_UPDATE,
    ])
);

const updateTelegramBot = async (params: MarketplaceTelegramBot) => {
  try {
    wait.start(Wait.MARKETPLACE_TELEGRAM_BOT_UPDATE);
    await apiMarketplaceTelegramBotUpdateSelf(params);
    await fetchTelegramBot();
    telegramBotModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_TELEGRAM_BOT_UPDATE);
  }
};

const fetchTelegramBot = async () => {
  try {
    wait.start(Wait.MARKETPLACE_TELEGRAM_BOT_FETCH);
    telegramBot.value = await apiMarketplaceTelegramBotGetSelf();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_TELEGRAM_BOT_FETCH);
  }
};

fetchTelegramBot();
</script>
