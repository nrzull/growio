<template>
  <Modal v-if="promise" @close="reject?.()">
    <template #heading>
      <slot name="heading"></slot>
    </template>

    <template #default>
      <slot></slot>
    </template>

    <template #footer>
      <slot name="footer" v-bind="{ resolve, reject }"></slot>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref } from "vue";
import Modal from "~/components/Modal.vue";

const promise = ref<Promise<unknown>>();
const resolve = ref();
const reject = ref();

const confirm = async () => {
  promise.value = new Promise((res, rej) => {
    resolve.value = res;
    reject.value = rej;
  });

  return new Promise((res, rej) =>
    promise.value
      .then(res)
      .catch(rej)
      .finally(() => (promise.value = undefined))
  );
};

defineExpose({ confirm });
</script>
