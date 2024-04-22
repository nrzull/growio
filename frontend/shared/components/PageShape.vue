<template>
  <Shape full-height :class="$style.shape">
    <div v-if="'tools' in $slots || 'heading' in $slots" :class="$style.head">
      <div :class="$style.heading">
        <slot name="heading" />
      </div>

      <div v-if="'tools' in $slots" :class="$style.tools">
        <slot name="tools" />
      </div>
    </div>

    <slot></slot>
  </Shape>
</template>

<script setup lang="ts">
import Shape from "@growio/shared/components/Shape.vue";
</script>

<style module>
.shape {
  display: flex;
  flex-flow: column;
  gap: 24px;
}

.head {
  display: flex;
  justify-content: space-between;
  gap: 8px;
}

.heading {
  font-size: 18px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.tools {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
</style>
