<template>
  <Modal @close="$emit('close')">
    <template #heading>Create Category</template>

    <div :class="$style.row">
      <TextInput v-model="name" placeholder="Name" />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', { name })">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import Button from "~/components/Button.vue";

const name = ref();
const emit = defineEmits({
  close: () => true,
  submit: (_v: { name: string }) => true,
});
</script>

<style module>
.row {
  display: grid;
  gap: 8px;
}
</style>
