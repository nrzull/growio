<template>
  <PageLoader :loading="isLoading" />

  <TelegramBotModal
    v-if="telegramBotModal"
    :model-value="telegramBotModal"
    @close="telegramBotModal = undefined"
    @submit="handleSubmitTelegramBot"
  />

  <PageShape>
    <template #heading>
      <slot name="tabs"></slot>
    </template>

    <template #tools>
      <Menu
        :items="[
          {
            id: 'telegram-bot',
            title: 'Telegram Bot',
            action: () =>
              (telegramBotModal = buildMarketplaceMarketTelegramBotNew()),
          },
        ]"
        @click:item="$event.action?.()"
      >
        <Button size="sm" icon="plus">Create</Button>
      </Menu>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ text: 'There is no integrations', type: 'info' }"
    />
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import PageShape from "~/components/PageShape.vue";
import PageLoader from "~/components/PageLoader.vue";
import { Wait, wait } from "~/composables/wait";
import Notification from "~/components/Notifications/Notification.vue";
import {
  MarketplaceMarketTelegramBot,
  MarketplaceMarketTelegramBotNew,
} from "~/api/growio/marketplace_market_telegram_bots/types";
import Button from "~/components/Button.vue";
import Menu from "~/components/Menu.vue";
import { buildMarketplaceMarketTelegramBotNew } from "~/api/growio/marketplace_market_telegram_bots/utils";
import TelegramBotModal from "~/components/Market/Integrations/TelegramBotModal.vue";

const integrations = ref<MarketplaceMarketTelegramBot[]>([]);

const telegramBotModal = ref<
  MarketplaceMarketTelegramBot | MarketplaceMarketTelegramBotNew
>();

const isLoading = computed(() =>
  wait.some([Wait.MARKETPLACE_MARKET_INTEGRATIONS_FETCH])
);

const isEmpty = computed(() => !isLoading.value && !integrations.value.length);

const handleSubmitTelegramBot = () => {};
</script>
