<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceMarketTelegramBot(modelValue)" #heading>
      <span>{{ modelValue.name }}</span> <Tag>Telegram Bot</Tag>
    </template>
    <template v-else #heading> Create Telegram Bot </template>

    <div :class="$style.grid">
      <div :class="$style.row">
        <TextInput v-model="telegramBot.name" placeholder="Name" />
        <TextInput
          v-model="telegramBot.description"
          placeholder="Description"
        />
      </div>

      <div :class="$style.row">
        <TextInput
          v-model="telegramBot.token"
          type="password"
          placeholder="Token"
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
import Tag from "~/components/Tag.vue";

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
