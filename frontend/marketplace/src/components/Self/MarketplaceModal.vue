<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template #heading>Create Marketplace</template>

    <div :class="$style.row">
      <TextInput v-model="model.name" placeholder="Name" />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', model)">Save</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import Modal from "@growio/shared/components/Modal.vue";
import { computed, ref } from "vue";
import Button from "@growio/shared/components/Button.vue";
import TextInput from "@growio/shared/components/TextInput.vue";

const props = defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
});

defineEmits({
  close: () => true,
  submit: (_v: { name: string }) => true,
});

const model = ref<{ name: string }>({ name: undefined });
const isLoading = computed(() => props.loading);
</script>

<style module>
.row {
  display: grid;
  gap: 8px;
  grid-template-columns: 1fr;
}
</style>
