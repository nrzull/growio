<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceMarketTelegramBot(modelValue)" #heading>
      Telegram Bot
    </template>
    <template v-else #heading> Connect Telegram Bot </template>

    <div :class="$style.grid">
      <div :class="$style.row">
        <TextInput placeholder="Name" v-model="telegramBot.name" />

        <TextInput
          v-model="telegramBot.token"
          type="password"
          placeholder="Token"
        />
      </div>

      <div :class="$style.row">
        <TextInput
          placeholder="Description on the bot's profile"
          v-model="telegramBot.short_description"
        />
      </div>

      <div :class="$style.row">
        <TextInput
          placeholder="Description in the chat with the bot if the chat is empty"
          v-model="telegramBot.description"
        />
      </div>

      <div :class="$style.row">
        <TextInput
          placeholder="Welcome Message"
          v-model="telegramBot.welcome_message"
        />
      </div>
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', telegramBot)">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import Button from "~/components/Button.vue";
import {
  MarketplaceMarketTelegramBot,
  MarketplaceMarketTelegramBotNew,
} from "~/api/growio/marketplace_market_telegram_bots/types";
import { isMarketplaceMarketTelegramBot } from "~/api/growio/marketplace_market_telegram_bots/utils";
import { clone } from "remeda";

const props = defineProps({
  modelValue: {
    type: Object as PropType<
      MarketplaceMarketTelegramBot | MarketplaceMarketTelegramBotNew
    >,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const isLoading = computed(() => props.loading);

const telegramBot = ref<
  MarketplaceMarketTelegramBot | MarketplaceMarketTelegramBotNew
>(clone(props.modelValue));

const emit = defineEmits({
  close: () => true,
  submit: (
    _v: MarketplaceMarketTelegramBot | MarketplaceMarketTelegramBotNew
  ) => true,
});
</script>

<style module>
.grid {
  display: grid;
  gap: 12px;
}

.row {
  display: flex;
  gap: 8px;
}
</style>
