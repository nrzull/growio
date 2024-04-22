<template>
  <section
    :class="[
      $style.shape,
      $style[type],
      {
        [$style.borderless]: borderless,
        [$style.paddingless]: paddingless,
        [$style.fullHeight]: fullHeight,
      },
    ]"
  >
    <slot />
  </section>
</template>

<script setup lang="ts">
defineProps({
  type: {
    type: String,
    default: "",
  },

  paddingless: {
    type: Boolean,
    default: false,
  },

  borderless: {
    type: Boolean,
    default: false,
  },

  fullHeight: {
    type: Boolean,
    default: false,
  },
});
</script>

<style module>
.shape {
  border-radius: 8px;
  padding: 36px 24px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.025);
  border: 1px solid rgba(0, 0, 0, 0.05);
  background-color: #fff;
}

.shape.secondary {
  background-color: var(--background-color);
  box-shadow: none;
}

.shape.paddingless {
  padding: 0px;
}

.shape.borderless {
  border-color: transparent;
}

.shape.fullHeight {
  min-height: 100%;
}
</style>
