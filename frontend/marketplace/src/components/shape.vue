<template>
  <section :class="$style.shape">
    <slot />
  </section>
</template>

<style module>
.shape {
  border-radius: 8px;
  padding: 36px 24px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.025);
  border: 1px solid rgba(0, 0, 0, 0.05);
  background-color: #fff;
}
</style>
