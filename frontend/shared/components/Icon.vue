<template>
  <div
    :class="[$style.icon, $style[size], { [$style.clickable]: clickable }]"
    v-html="icon"
  ></div>
</template>

<script setup lang="ts">
import { PropType, computed } from "vue";
import users from "@growio/shared/assets/users.svg?raw";
import adProduct from "@growio/shared/assets/ad-product.svg?raw";
import settings01 from "@growio/shared/assets/settings-01.svg?raw";
import plus from "@growio/shared/assets/plus.svg?raw";
import trashCircle from "@growio/shared/assets/trash-circle.svg?raw";
import arrowRightFromBracket from "@growio/shared/assets/arrow-right-from-bracket.svg?raw";
import chevronDown from "@growio/shared/assets/chevron-down.svg?raw";
import storeSolid from "@growio/shared/assets/store-solid.svg?raw";
import order from "@growio/shared/assets/order.svg?raw";
import analytics from "@growio/shared/assets/analytics.svg?raw";
import support from "@growio/shared/assets/support.svg?raw";
import editRegular from "@growio/shared/assets/edit-regular.svg?raw";
import folderFilled from "@growio/shared/assets/folder-filled.svg?raw";
import telegramFilled from "@growio/shared/assets/telegram-filled.svg?raw";
import arrowBack from "@growio/shared/assets/arrow-back.svg?raw";

const icons = {
  users,
  adProduct,
  settings01,
  plus,
  trashCircle,
  arrowRightFromBracket,
  chevronDown,
  storeSolid,
  order,
  analytics,
  support,
  editRegular,
  folderFilled,
  telegramFilled,
  arrowBack,
} as const;

export type Icons = keyof typeof icons;

const props = defineProps({
  value: {
    type: String as PropType<Icons>,
    required: true,
  },

  clickable: {
    type: Boolean,
    default: false,
  },

  size: {
    type: String as PropType<"sm" | "md" | "lg">,
    default: "md",
  },
});

const icon = computed(() => icons[props.value]);
</script>

<style module>
.icon {
  display: inline-flex;
}

.icon.clickable {
  cursor: pointer;
}

.lg svg {
  height: 32px;
  width: 32px;
  min-width: 32px;
}

.md svg {
  height: 19px;
  width: 19px;
  min-width: 19px;
}

.sm svg {
  height: 14px;
  width: 14px;
  min-width: 14px;
}
</style>
