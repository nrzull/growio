<template>
  <div :class="$style.tag">
    <slot></slot>
  </div>
</template>

<style module>
.tag {
  display: inline-flex;
  border-radius: 8px;
  padding: 2px 8px;
  background-color: var(--color-gray-100);
  font-size: 10px;
  font-weight: bold;
  text-transform: uppercase;
}
</style>
