<template>
  <div :class="$attrs.class">
    <div
      ref="triggerRef"
      :class="$style.trigger"
      @click.stop="manual ? $emit('click:trigger', !open) : (open = !open)"
    >
      <slot name="trigger"></slot>
    </div>

    <div
      v-if="open"
      ref="floatingRef"
      :style="floatingStyles"
      :class="[$style.floating, floatingClass]"
    >
      <slot></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, PropType } from "vue";
import { useFloating, autoUpdate, UseFloatingOptions } from "@floating-ui/vue";
import { mergeDeep } from "remeda";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  manual: {
    type: Boolean,
    default: false,
  },

  useFloatingOptions: {
    type: Object as PropType<UseFloatingOptions>,
    default: () => ({}),
  },

  floatingClass: {
    type: String,
    default: undefined,
  },
});

defineEmits({ "click:trigger": (_v: boolean) => true });

const triggerRef = ref<HTMLDivElement>();
const floatingRef = ref<HTMLDivElement>();

const open = ref(false);
const setOpen = (v: boolean) => (open.value = v);

const minWidth = computed(() => {
  const value = triggerRef.value?.getBoundingClientRect()?.width;

  if (typeof value === "number") {
    return `${value}px`;
  }
});

const { floatingStyles } = useFloating(
  triggerRef,
  floatingRef,
  mergeDeep(
    {
      whileElementsMounted: autoUpdate,
      open,
      placement: "bottom-end",
    } as UseFloatingOptions,
    props.useFloatingOptions
  )
);

defineExpose({ open, setOpen });
</script>

<style module>
.trigger {
  cursor: pointer;
  width: 100%;
}

.floating {
  min-width: v-bind(minWidth);
}
</style>
