<template>
  <Shape full-height :class="$style.shape">
    <div
      v-if="['tools', 'heading', 'subheading'].some((v) => v in $slots)"
      :class="$style.head"
    >
      <div v-if="['heading', 'subheading'].some((v) => v in $slots)">
        <div :class="$style.heading">
          <slot name="heading" />
        </div>

        <div :class="$style.subheading">
          <slot name="subheading" />
        </div>
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
  display: flex;
  align-items: center;
  gap: 8px;
}

.subheading {
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.tools {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
</style>
