import { ref, computed, onUnmounted } from "vue";

const modals = ref<string[]>([]);

export const useModal = () => {
  const id = String(Math.floor(Math.random() * 1000000) + 1);
  modals.value.push(id);

  const baseZIndex = parseInt(
    getComputedStyle(document.body).getPropertyValue("--z-index-modal")
  );

  const zIndex = computed(
    () => baseZIndex + modals.value.findIndex((v) => v === id)
  );

  onUnmounted(() => (modals.value = modals.value.filter((v) => v !== id)));

  return { zIndex };
};
