<template>
  <Modal @close="$emit('close')">
    <template #heading>Invite User</template>

    <div>
      <TextInput placeholder="Email" />
    </div>

    <template #footer>
      <Button size="md">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import Button from "~/components/Button.vue";

defineEmits(["close"]);
</script>
