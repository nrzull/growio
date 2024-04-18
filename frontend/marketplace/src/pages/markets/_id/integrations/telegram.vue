<template>
  <RouterView v-slot="{ Component }">
    <component :is="Component" v-bind="$props">
      <template #tabs>
        <Tabs>
          <RouterLink
            :to="`/markets/${market.id}/integrations`"
            custom
            v-slot="{ navigate }"
          >
            <Button type="neutral" size="md" icon="arrowBack" @click="navigate">
              {{ market.name }}
            </Button>
          </RouterLink>

          <Button type="neutral" size="md" icon="telegramFilled">
            Telegram Bot
          </Button>
        </Tabs>
      </template>
    </component>
  </RouterView>
</template>

<script setup lang="ts">
import { PropType } from "vue";
import { MarketplaceMarket } from "~/api/growio/marketplace_markets/types";
import Button from "~/components/Button.vue";
import Tabs from "~/components/Tabs.vue";

defineProps({
  market: {
    type: Object as PropType<MarketplaceMarket>,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});
</script>
