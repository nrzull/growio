<template>
  <div :class="$style.heading">
    <slot />
  </div>
</template>

<style module>
.heading {
  font-size: 24px;
  font-weight: 500;
}
</style>
