<template>
  <Modal size="lg" @close="$emit('close')">
    <template #heading>Invitations</template>
  </Modal>
</template>

<script setup lang="ts">
import Modal from "~/components/Modal.vue";

defineEmits(["close"]);
</script>
