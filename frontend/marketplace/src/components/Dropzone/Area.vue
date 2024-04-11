<template>
  <div :class="[$style.area, { [$style.empty]: !files.length }]">
    <div v-if="!files.length">Place your files here</div>

    <div :class="$style.images">
      <div v-for="(file, i) in files" :key="i" :class="$style.imageWrapper">
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
  </div>
</template>

<script setup lang="ts">
import { PropType } from "vue";
import { DropzoneFile } from "~/components/Dropzone/types";
import Icon from "~/components/Icon.vue";

defineProps({
  files: {
    type: Array as PropType<Array<DropzoneFile>>,
    default: () => [],
  },
});

defineEmits(["remove:file", "click:file"]);
</script>

<style module>
.area {
  height: 200px;
  border: 1px dotted var(--color-gray-100);
  display: flex;
  border-radius: 8px;
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
}

.imageWrapper:hover .actions {
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
