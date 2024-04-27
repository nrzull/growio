<template>
  <PageLoader :loading="isLoading" />

  <RouterView v-if="payload" v-slot="{ Component }">
    <component :is="Component">
      <template #heading>
        {{ payload.marketplace.name }}

        <a
          v-if="telegramBotLink"
          :href="telegramBotLink"
          target="_blank"
          rel="nofollow"
          :class="$style.link"
        >
          <Icon value="telegramFilled" />
        </a>
      </template>

      <template v-if="payload.marketplace.address" #subheading>
        {{ payload.marketplace.address }}
      </template>
    </component>
  </RouterView>
</template>

<script setup lang="ts">
import { Wait, wait } from "@growio/shared/composables/wait";
import { computed } from "vue";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import Icon from "@growio/shared/components/Icon.vue";
import { payload } from "~/composables/payload";

const isLoading = computed(() => wait.some([Wait.MARKETPLACE_PAYLOAD_FETCH]));

const telegramBotLink = computed(() => {
  const tag = payload.value.integrations.find((v) => v.is_telegram)?.tag;

  if (tag) {
    return `https://t.me/${tag}`;
  }
});
</script>

<style module>
.link {
  display: inline-flex;
  align-items: center;
  color: unset;
}
</style>
