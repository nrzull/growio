<template>
  <div :class="$style.tabs">
    <slot></slot>
  </div>
</template>

<style module>
.tabs {
  display: inline-flex;
  gap: 8px;
  align-items: center;
}
</style>
