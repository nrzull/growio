<template>
  <div
    v-bind="wrapperAttrs"
    :class="$style.wrapper"
  >
    <div :class="$style.textInputWrapper">
      <label
        v-if="$attrs.placeholder"
        :class="[
          $style.placeholder,
          {
            [$style.focused]: focused || modelValue,
            [$style.invalid]: isInvalid,
          },
        ]"
      >
        {{ $attrs.placeholder }}
      </label>

      <input
        type="text"
        v-bind="inputAttrs"
        :class="[$style.textInput, { [$style.invalid]: isInvalid }]"
        :value="modelValue"
        @focus="focused = true"
        @blur="focused = false"
        @input="(ev: any) => $emit('update:model-value', ev.target?.value!)"
      >
    </div>

    <div
      v-if="
        (Array.isArray(errors) || typeof errors === 'string') && errors.length
      "
      :class="$style.errors"
    >
      <template v-if="Array.isArray(errors)">
        {{ errors.join(", ") }}
      </template>
      <template v-else>
        {{ errors }}
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  PropType,
  computed,
  ref,
  defineEmits,
  defineProps,
  useAttrs,
  defineOptions,
} from "vue";
import { pick } from "remeda";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  modelValue: {
    type: [String, Number],
    default: "",
  },

  errors: {
    type: [Boolean, String, Array] as PropType<string | boolean | string[]>,
    default: undefined,
  },
});

defineEmits(["update:model-value"]);

const attrs = useAttrs();

const focused = ref(false);

const wrapperAttrs = computed(() =>
  pick(attrs, ["class", "style"])
) as unknown as typeof attrs;

const inputAttrs = computed(
  () => pick(attrs, ["type", "readonly", "disabled"]) as unknown as typeof attrs
);

const isInvalid = computed(() =>
  Array.isArray(props.errors)
    ? !!props.errors.length
    : ["string", "boolean"].includes(typeof props.errors)
    ? props.errors
    : false
);
</script>

<style module>
.wrapper,
.textInputWrapper {
  position: relative;
}

.textInput {
  all: unset;
  width: 100%;
  box-sizing: border-box;
  border: 1px solid rgba(0, 0, 0, 0.1);
  padding: 16px;
  border-radius: 6px;
  transition: border-color 0.2s ease;
  z-index: var(--z-index-text-input);
  position: relative;
}

.textInput.invalid {
  border-color: var(--color-red);
}

.textInput:not(.invalid):focus {
  border-color: var(--color-primary);
}

.placeholder {
  display: inline-flex;
  margin-bottom: 4px;
  font-weight: 500;
  color: var(--color-gray-400);
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  left: 16px;
  z-index: var(--z-index-text-input-placeholder);
  transition: all 0.2s ease;
  font-size: 14px;
}

.placeholder.invalid {
  color: var(--color-red);
}

.placeholder.focused {
  top: 0;
  z-index: var(--z-index-text-input-placeholder-focused);
  background-color: #fff;
  left: 12px;
  padding: 0 4px;
}

.errors {
  padding: 0 4px;
  margin-top: 4px;
  color: var(--color-red);
  font-size: 12px;
  font-weight: 500;
}
</style>
