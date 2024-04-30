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
    <template #heading> Integrations </template>

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
        <template v-if="isMarketplaceTelegramBot(ctx.row.original)">
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
import PageShape from "@growio/shared/components/PageShape.vue";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import { Wait, wait } from "@growio/shared/composables/wait";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import {
  MarketplaceTelegramBot,
  MarketplaceTelegramBotNew,
} from "@growio/shared/api/growio/marketplace_telegram_bots/types";
import Button from "@growio/shared/components/Button.vue";
import Menu from "@growio/shared/components/Menu.vue";
import {
  buildMarketplaceTelegramBotNew,
  isMarketplaceTelegramBot,
} from "@growio/shared/api/growio/marketplace_telegram_bots/utils";
import TelegramBotModal from "~/components/Integrations/TelegramBotModal.vue";
import {
  apiMarketplaceTelegramBotsCreate,
  apiMarketplaceTelegramBotsDelete,
} from "@growio/shared/api/growio/marketplace_telegram_bots";
import Table from "@growio/shared/components/Table.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import Icon from "@growio/shared/components/Icon.vue";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import { useRouter } from "vue-router";
import { apiMarketplaceGetAllIntegrations } from "@growio/shared/api/growio/marketplaces";

const props = defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
});

const router = useRouter();

const integrations = ref<MarketplaceTelegramBot[]>([]);

const telegramBotModal = ref<
  MarketplaceTelegramBot | MarketplaceTelegramBotNew
>();

const deleteMarketTelegramBotModalRef =
  ref<InstanceType<typeof PromiseModal>>();

const hasTelegramBotIntegration = computed(() =>
  integrations.value.some(isMarketplaceTelegramBot)
);

const createMenuItems = computed(() =>
  [
    hasTelegramBotIntegration.value
      ? undefined
      : {
          id: "telegram-bot",
          title: "Telegram Bot",
          action: () =>
            (telegramBotModal.value = buildMarketplaceTelegramBotNew()),
        },
  ].filter((v) => v)
);

const isLoading = computed(
  () =>
    props.loading ||
    wait.some([
      Wait.MARKETPLACE_INTEGRATIONS_FETCH,
      Wait.MARKETPLACE_TELEGRAM_BOT_CREATE,
      Wait.MARKETPLACE_TELEGRAM_BOT_DELETE,
    ])
);

const isEmpty = computed(() => !isLoading.value && !integrations.value.length);

const columnHelper = createColumnHelper<MarketplaceTelegramBot>();

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
  params: MarketplaceTelegramBot | MarketplaceTelegramBotNew
) =>
  isMarketplaceTelegramBot(params)
    ? updateTelegramBot(params)
    : createTelegramBot(params);

const createTelegramBot = async (params: MarketplaceTelegramBotNew) => {
  try {
    wait.start(Wait.MARKETPLACE_TELEGRAM_BOT_CREATE);
    await apiMarketplaceTelegramBotsCreate(params);
    await fetchIntegrations();
    telegramBotModal.value = undefined;
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_TELEGRAM_BOT_CREATE);
  }
};

const clickIntegration = (params: MarketplaceTelegramBot) =>
  isMarketplaceTelegramBot(params)
    ? router.push(`/settings/integrations/telegram`)
    : null;

const deleteIntegration = (params: MarketplaceTelegramBot) =>
  isMarketplaceTelegramBot(params) ? deleteTelegramBot(params) : null;

const deleteTelegramBot = async (params: MarketplaceTelegramBot) => {
  try {
    await deleteMarketTelegramBotModalRef.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_TELEGRAM_BOT_DELETE);
    await apiMarketplaceTelegramBotsDelete(params);
    await fetchIntegrations();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_TELEGRAM_BOT_DELETE);
  }
};

const updateTelegramBot = async (params: MarketplaceTelegramBot) => {};

const fetchIntegrations = async () => {
  try {
    wait.start(Wait.MARKETPLACE_INTEGRATIONS_FETCH);
    integrations.value = await apiMarketplaceGetAllIntegrations();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_INTEGRATIONS_FETCH);
  }
};

fetchIntegrations();
</script>
