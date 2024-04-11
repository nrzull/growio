<template>
  <div :class="$style.dropzone">
    <input
      ref="inputRef"
      type="file"
      :class="$style.input"
      multiple
      @change="handleInputChange"
    />

    <slot
      v-if="proxyModelValue.length || readonly"
      v-bind="{ files: proxyModelValue }"
    >
      <Area :files="proxyModelValue" @remove:file="removeFile" />
    </slot>
    <Area
      v-else
      :files="proxyModelValue"
      @click="inputRef?.click?.()"
      @remove:file="removeFile"
    >
    </Area>
  </div>
</template>

<script setup lang="ts">
import { PropType, ref, computed } from "vue";
import { DropzoneFile } from "~/components/Dropzone/types";
import { intoDropzoneFile } from "~/components/Dropzone/utils";
import Area from "~/components/Dropzone/Area.vue";

const props = defineProps({
  modelValue: {
    type: Array as PropType<Array<File | DropzoneFile>>,
    default: () => [],
  },

  readonly: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["update:model-value"]);

const inputRef = ref<HTMLInputElement>();

const proxyModelValue = computed({
  get: () => props.modelValue.map(intoDropzoneFile),
  set: (v) => emit("update:model-value", v),
});

const handleInputChange = (v: any) => {
  const files = Array.from((v.target.files as FileList) || []);

  if (!files?.length) {
    return;
  }

  proxyModelValue.value = files.map(intoDropzoneFile);
};

const removeFile = (v: DropzoneFile) => {
  proxyModelValue.value = proxyModelValue.value.filter(
    (vv) => vv.src !== v.src
  );
};
</script>

<style module>
.input {
  visibility: hidden;
  z-index: -1;
  position: absolute;
}
</style>
