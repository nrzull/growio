<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceTelegramBot(modelValue)" #heading>
      Telegram Bot
    </template>
    <template v-else #heading> Connect Telegram Bot </template>

    <div :class="$style.grid">
      <div :class="$style.row">
        <TextInput v-model="telegramBot.name" placeholder="Name" />

        <TextInput
          v-model="telegramBot.token"
          type="password"
          placeholder="Token"
        />
      </div>

      <div :class="$style.row">
        <TextInput
          v-model="telegramBot.short_description"
          placeholder="Short Description"
        />
      </div>

      <div :class="$style.row">
        <TextInput
          v-model="telegramBot.description"
          placeholder="Description"
        />
      </div>

      <div :class="$style.row">
        <TextInput
          v-model="telegramBot.welcome_message"
          placeholder="Welcome Message"
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
import Modal from "@growio/shared/components/Modal.vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import Button from "@growio/shared/components/Button.vue";
import {
  MarketplaceTelegramBot,
  MarketplaceTelegramBotNew,
} from "@growio/shared/api/growio/marketplace_telegram_bots/types";
import { isMarketplaceTelegramBot } from "@growio/shared/api/growio/marketplace_telegram_bots/utils";
import { clone } from "remeda";

const props = defineProps({
  modelValue: {
    type: Object as PropType<
      MarketplaceTelegramBot | MarketplaceTelegramBotNew
    >,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const isLoading = computed(() => props.loading);

const telegramBot = ref<MarketplaceTelegramBot | MarketplaceTelegramBotNew>(
  clone(props.modelValue)
);

const emit = defineEmits({
  close: () => true,
  submit: (_v: MarketplaceTelegramBot | MarketplaceTelegramBotNew) => true,
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
