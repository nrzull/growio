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

          <Button type="neutral" size="md" icon="editRegular">
            Telegram Bot
          </Button>

          <RouterLink
            :to="`/markets/${market.id}/integrations/telegram/general`"
            custom
            v-slot="{ navigate, isActive }"
          >
            <Button
              type="neutral"
              size="md"
              @click="navigate"
              :active="isActive"
            >
              General
            </Button>
          </RouterLink>

          <RouterLink
            :to="`/markets/${market.id}/integrations/telegram/mailing`"
            custom
            v-slot="{ navigate, isActive }"
          >
            <Button
              type="neutral"
              size="md"
              @click="navigate"
              :active="isActive"
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
