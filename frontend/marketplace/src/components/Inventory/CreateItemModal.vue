<template>
  <Modal @close="$emit('close')">
    <template #heading>Create Item</template>

    <div :class="$style.row">
      <TextInput v-model="name" placeholder="Name" />
      <SelectInput
        v-model="category"
        placeholder="Category"
        track-by="id"
        label-path="name"
        :items="categories"
      />
    </div>

    <template #footer>
      <Button size="md" @click="submit">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import SelectInput from "~/components/SelectInput.vue";
import Button from "~/components/Button.vue";
import { MarketplaceItemCategory } from "~/api/growio/marketplace_item_categories/types";
import { apiMarketplaceItemCategoriesGetAll } from "~/api/growio/marketplace_item_categories";
import { IdParam } from "~/api/types";

const name = ref();
const category = ref<MarketplaceItemCategory>();
const categories = ref<MarketplaceItemCategory[]>([]);

const emit = defineEmits({
  close: () => true,
  submit: (_v: { name: string; category_id: IdParam }) => true,
});

const submit = async () => {
  emit("submit", { name: name.value, category_id: category.value.id });
};

apiMarketplaceItemCategoriesGetAll({ deleted_at: false }).then(
  (r) => (categories.value = r)
);
</script>

<style module>
.row {
  display: flex;
  gap: 8px;
}
</style>
