<template>
  <div :class="$style.sidebar">
    <RouterLink to="/">dashboard</RouterLink>
  </div>
</template>

<style module>
.sidebar {
  background-color: var(--color-white);
  border-right: 1px solid var(--color-gray-100);
  padding: 20px;
  display: flex;
  flex-flow: column;
  align-items: center;
  gap: 24px;
  overflow-y: auto;
}
</style>
