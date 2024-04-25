<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template #heading>Create Marketplace</template>

    <div :class="$style.row">
      <TextInput v-model="model.name" placeholder="Name" />
      <SelectInput
        v-model="model.currency"
        placeholder="Currency"
        :items="currencies"
      />
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
import SelectInput from "@growio/shared/components/SelectInput.vue";
import { Currency, currencies } from "@growio/shared/utils/money";

type Model = { name: string; currency: Currency };

const props = defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
});

defineEmits({
  close: () => true,
  submit: (_v: Model) => true,
});

const model = ref<Model>({ name: undefined, currency: undefined });
const isLoading = computed(() => props.loading);
</script>

<style module>
.row {
  display: grid;
  gap: 8px;
  grid-template-columns: 1fr;
}
</style>
