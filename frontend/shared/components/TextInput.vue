<template>
  <div v-bind="wrapperAttrs" :class="$style.wrapper">
    <div :class="$style.textInputWrapper">
      <label
        v-if="$attrs.placeholder"
        :class="[
          $style.placeholder,
          {
            [$style.focused]:
              focused || typeof modelValue === 'number' ? true : modelValue,
            [$style.invalid]: isInvalid,
            [$style.textable]:
              !focused &&
              !modelValue &&
              !inputAttrs.readonly &&
              !inputAttrs.disabled,
          },
        ]"
        @click="setFocus(true)"
      >
        {{ $attrs.placeholder }}
      </label>

      <input
        ref="inputRef"
        type="text"
        v-bind="inputAttrs"
        :class="[
          innerInputClass,
          $style.textInput,
          { [$style.invalid]: isInvalid },
        ]"
        :value="modelValue"
        @focus="setFocus(true)"
        @blur="setFocus(false)"
        @input="(ev: any) => $emit('update:model-value', ev.target?.value!)"
      />
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
import { PropType, computed, ref, useAttrs } from "vue";
import { pick, omit } from "remeda";

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

  innerInputClass: {
    type: String,
    default: undefined,
  },
});

defineEmits(["update:model-value"]);

const attrs = useAttrs() as Record<any, any>;
const inputRef = ref<HTMLInputElement>();
const focused = ref(false);

const setFocus = (v: boolean) => {
  focused.value = v;
  v ? attrs.onFocus?.(v) : attrs.onBlur?.(v);

  if (v) {
    inputRef.value?.focus?.();
  } else {
    inputRef.value?.blur?.();
  }
};

const wrapperAttrs = computed(() =>
  pick(attrs, ["class", "style"])
) as unknown as typeof attrs;

const inputAttrs = computed(() =>
  omit(attrs, ["class", "style", "placeholder"])
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
  flex: 1;
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
  background-color: var(--color-gray-10);
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
  transition: all 0.2s ease;
  font-size: 14px;
  z-index: var(--z-index-text-input-placeholder);
  user-select: none;
}

.placeholder.invalid {
  color: var(--color-red);
}

.placeholder.textable {
  cursor: text;
}

.placeholder.focused {
  top: 0px;
  left: 12px;
  line-height: 1;
  padding: 0 2px;
  border-radius: 4px;
  background: linear-gradient(to bottom, #fff 60%, transparent 40%);
}

.errors {
  padding: 0 4px;
  margin-top: 4px;
  color: var(--color-red);
  font-size: 12px;
  font-weight: 500;
}
</style>
