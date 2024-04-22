<template>
  <div :class="$style.dropzone">
    <input
      ref="inputRef"
      type="file"
      :class="$style.input"
      multiple
      @change="handleInputChange"
    />

    <slot v-if="model.length || readonly" v-bind="{ files: model }">
      <Area
        :track-by="trackBy"
        :files="model"
        @remove:file="removeFile"
        @add:file="inputRef?.click?.()"
      />
    </slot>
    <Area
      v-else
      :files="model"
      :track-by="trackBy"
      @click="inputRef?.click?.()"
    >
      <template #placeholder>
        <slot name="placeholder"></slot>
      </template>
    </Area>
  </div>
</template>

<script setup lang="ts">
import { PropType, ref, watch } from "vue";
import { DropzoneFile } from "@growio/shared/components/Dropzone/types";
import {
  intoDropzoneFile,
  fromDropzoneFile,
} from "@growio/shared/components/Dropzone/utils";
import Area from "@growio/shared/components/Dropzone/Area.vue";
import {
  MarketplaceItemAsset,
  PartialMarketplaceItemAsset,
} from "@growio/shared/api/growio/marketplace_item_assets/types";
import { JSONPath } from "jsonpath-plus";

const props = defineProps({
  input: {
    type: Array as PropType<
      Array<
        File | DropzoneFile | MarketplaceItemAsset | PartialMarketplaceItemAsset
      >
    >,
    default: () => [],
  },

  output: {
    type: Array as PropType<
      Array<MarketplaceItemAsset | PartialMarketplaceItemAsset>
    >,
    default: () => [],
  },

  outputCreate: {
    type: Array as PropType<
      Array<MarketplaceItemAsset | PartialMarketplaceItemAsset>
    >,
    default: () => [],
  },

  outputDelete: {
    type: Array as PropType<
      Array<MarketplaceItemAsset | PartialMarketplaceItemAsset>
    >,
    default: () => [],
  },

  trackBy: {
    type: String,
    default: "src",
  },

  readonly: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits({
  "update:output": (
    _v: Array<MarketplaceItemAsset | PartialMarketplaceItemAsset>
  ) => true,
  "update:outputCreate": (
    _v: Array<MarketplaceItemAsset | PartialMarketplaceItemAsset>
  ) => true,
  "update:outputDelete": (
    _v: Array<MarketplaceItemAsset | PartialMarketplaceItemAsset>
  ) => true,
});

const inputRef = ref<HTMLInputElement>();
const model = ref<DropzoneFile[]>([]);

watch(
  () => props.output,
  (output) => {
    const toCreate = output
      .filter((v) => !props.input.some((vv) => getKey(vv) === getKey(v)))
      .map((v) => v as unknown as PartialMarketplaceItemAsset);

    const toDelete = props.input
      .filter((v) => !output.some((vv) => getKey(vv) === getKey(v)))
      .map((v) => v as unknown as MarketplaceItemAsset);

    emit("update:outputCreate", toCreate);
    emit("update:outputDelete", toDelete);
  },
  { deep: true }
);

watch(
  () => model.value,
  (v) => emit("update:output", v.map(fromDropzoneFile)),
  { deep: true }
);

watch(
  () => props.input,
  (v) => (model.value = v.map(intoDropzoneFile)),
  { deep: true, immediate: true }
);

const getKey = (v) => {
  const [result] = JSONPath({ json: v, path: props.trackBy });
  return result;
};

const handleInputChange = (v) => {
  addFiles((v.target.files as FileList) || []);
};

const addFiles = (files: FileList | File[]) => {
  model.value = model.value.concat(
    Array.from(files)
      .map(intoDropzoneFile)
      .filter((f) => !model.value.some((ff) => ff.name === f.name))
  );
};

const removeFile = (v: DropzoneFile) => {
  model.value = model.value.filter((vv) => vv.src !== v.src);
};
</script>

<style module>
.input {
  visibility: hidden;
  z-index: -1;
  position: absolute;
}
</style>
