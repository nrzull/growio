<template>
  <div :class="[$style.area, { [$style.empty]: !files.length }]">
    <slot v-if="!files.length" name="placeholder"> Place your files here </slot>
    <template v-else>
      <div :class="$style.actions">
        <Icon :class="$style.action" value="plus" @click="$emit('add:file')" />
      </div>

      <div :class="$style.images">
        <div
          v-for="(file, i) in files"
          :key="getKey(file, i)"
          :class="$style.imageWrapper"
        >
          <div :class="$style.actions">
            <Icon
              :class="$style.action"
              value="trashCircle"
              @click="$emit('remove:file', file)"
            />
          </div>

          <img
            v-if="file.src"
            :src="file.src"
            :class="$style.image"
            @click="$emit('click:file', file)"
          />
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { JSONPath } from "jsonpath-plus";
import { PropType } from "vue";
import { DropzoneFile } from "~/components/Dropzone/types";
import Icon from "~/components/Icon.vue";

const props = defineProps({
  files: {
    type: Array as PropType<Array<DropzoneFile>>,
    default: () => [],
  },

  trackBy: {
    type: String,
    default: "src",
  },
});

defineEmits(["remove:file", "click:file", "add:file"]);

const getKey = (v, fallback) => {
  const [result] = JSONPath({ json: v, path: props.trackBy });
  return result || fallback;
};
</script>

<style module>
.area {
  height: 200px;
  display: flex;
  position: relative;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 6px;
  background-color: var(--color-gray-10);
}

.images {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding: 8px;
}

.imageWrapper {
  position: relative;
  width: auto;
  display: inline-flex;
}

.actions {
  position: absolute;
  top: 8px;
  right: 8px;
  background-color: rgba(255, 255, 255, 0.3);
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 4px;
  border-radius: 8px;
  backdrop-filter: blur(8px);
  visibility: hidden;
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.2s ease;
  opacity: 0;
  z-index: 1;
}

.area:hover > .actions {
  visibility: visible;
  opacity: 1;
}

.imageWrapper:hover > .actions {
  visibility: visible;
  opacity: 1;
}

.action {
  cursor: pointer;
}

.image {
  border-radius: 8px;
  object-fit: contain;
}

.area.empty {
  justify-content: center;
  align-items: center;
}
</style>
