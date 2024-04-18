<template>
  <PageLoader :loading="isLoading" />

  <TelegramBotModal
    v-if="telegramBotModal"
    :model-value="telegramBotModal"
    @close="telegramBotModal = undefined"
    @submit="handleSubmitTelegramBot"
  />

  <PromiseModal ref="deleteMarketTelegramBotModalRef">
    <template #heading>Delete telegram bot</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <PageShape>
    <template #heading>
      <slot name="tabs"></slot>
    </template>

    <template #tools>
      <Menu
        v-if="createMenuItems.length"
        :items="createMenuItems"
        @click:item="$event.action?.()"
      >
        <Button size="sm" icon="plus">Connect</Button>
      </Menu>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ text: 'There is no integrations', type: 'info' }"
    />
    <Table
      v-else
      :table
      clickable
      @click:row="clickIntegration($event.original)"
    >
      <template #name="{ ctx }">
        <template v-if="isMarketplaceMarketTelegramBot(ctx.row.original)">
          <Icon value="telegramFilled" />
          Telegram Bot
        </template>
        <template v-else>{{ ctx.row.original }}</template>
      </template>

      <template #actions="{ ctx }">
        <Button
          size="md"
          type="link-neutral"
          icon="trashCircle"
          @click.stop="deleteIntegration(ctx.row.original)"
        ></Button>
      </template>
    </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { ref, computed, PropType } from "vue";
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
import {
  buildMarketplaceMarketTelegramBotNew,
  isMarketplaceMarketTelegramBot,
} from "~/api/growio/marketplace_market_telegram_bots/utils";
import TelegramBotModal from "~/components/Market/Integrations/TelegramBotModal.vue";
import { apiMarketplaceMarketsGetAllIntegrations } from "~/api/growio/marketplace_markets";
import { MarketplaceMarket } from "~/api/growio/marketplace_markets/types";
import {
  apiMarketplaceMarketTelegramBotsCreate,
  apiMarketplaceMarketTelegramBotsDelete,
} from "~/api/growio/marketplace_market_telegram_bots";
import Table from "~/components/Table.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Icon from "~/components/Icon.vue";
import PromiseModal from "~/components/PromiseModal.vue";
import { useRouter } from "vue-router";

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

const router = useRouter();

const integrations = ref<MarketplaceMarketTelegramBot[]>([]);

const telegramBotModal = ref<
  MarketplaceMarketTelegramBot | MarketplaceMarketTelegramBotNew
>();

const deleteMarketTelegramBotModalRef =
  ref<InstanceType<typeof PromiseModal>>();

const hasTelegramBotIntegration = computed(() =>
  integrations.value.some(isMarketplaceMarketTelegramBot)
);

const createMenuItems = computed(() =>
  [
    hasTelegramBotIntegration.value
      ? undefined
      : {
          id: "telegram-bot",
          title: "Telegram Bot",
          action: () =>
            (telegramBotModal.value = buildMarketplaceMarketTelegramBotNew()),
        },
  ].filter((v) => v)
);

const isLoading = computed(
  () =>
    props.loading ||
    wait.some([
      Wait.MARKETPLACE_MARKET_INTEGRATIONS_FETCH,
      Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_CREATE,
      Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_DELETE,
    ])
);

const isEmpty = computed(() => !isLoading.value && !integrations.value.length);

const columnHelper = createColumnHelper<MarketplaceMarketTelegramBot>();

const columns = ref([
  columnHelper.display({
    id: "name",
  }),

  columnHelper.display({
    id: "actions",

    meta: {
      style: {
        width: "0",
      },
    },
  }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return integrations.value;
  },

  get columns() {
    return columns.value;
  },
});

const handleSubmitTelegramBot = (
  params: MarketplaceMarketTelegramBot | MarketplaceMarketTelegramBotNew
) =>
  isMarketplaceMarketTelegramBot(params)
    ? updateTelegramBot(params)
    : createTelegramBot(params);

const createTelegramBot = async (params: MarketplaceMarketTelegramBotNew) => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_CREATE);
    await apiMarketplaceMarketTelegramBotsCreate({
      ...params,
      marketplace_market_id: props.market.id,
    });
    await fetchIntegrations();
    telegramBotModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_CREATE);
  }
};

const clickIntegration = (params: MarketplaceMarketTelegramBot) =>
  isMarketplaceMarketTelegramBot(params)
    ? router.push(`/markets/${props.market.id}/integrations/telegram`)
    : null;

const deleteIntegration = (params: MarketplaceMarketTelegramBot) =>
  isMarketplaceMarketTelegramBot(params) ? deleteTelegramBot(params) : null;

const deleteTelegramBot = async (params: MarketplaceMarketTelegramBot) => {
  try {
    await deleteMarketTelegramBotModalRef.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_DELETE);
    await apiMarketplaceMarketTelegramBotsDelete(params);
    await fetchIntegrations();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_TELEGRAM_BOT_DELETE);
  }
};

const updateTelegramBot = async (params: MarketplaceMarketTelegramBot) => {};

const fetchIntegrations = async () => {
  try {
    wait.start(Wait.MARKETPLACE_MARKET_INTEGRATIONS_FETCH);
    integrations.value = await apiMarketplaceMarketsGetAllIntegrations(
      props.market
    );
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_MARKET_INTEGRATIONS_FETCH);
  }
};

fetchIntegrations();
</script>
