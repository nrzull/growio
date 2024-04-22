<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="!!modelValue.id" #heading>
      <span>{{ modelValue.email }}</span> <Tag>Invitation</Tag>
    </template>
    <template v-else #heading> Invite User </template>

    <div :class="$style.row">
      <TextInput v-model="model.email" placeholder="Email" />
      <SelectInput
        v-model="role"
        placeholder="Role"
        track-by="id"
        label-path="name"
        :items="roles"
      />
    </div>

    <template #footer>
      <Button size="md" @click="$emit('submit', model)">Submit</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, ref, computed, watch } from "vue";
import Modal from "@growio/shared/components/Modal.vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import SelectInput from "@growio/shared/components/SelectInput.vue";
import Button from "@growio/shared/components/Button.vue";
import { apiMarketplaceAccountRolesGetAll } from "@growio/shared/api/growio/marketplace_account_roles";
import { MarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/types";
import { clone } from "remeda";
import { wait, Wait } from "@growio/shared/composables/wait";
import Tag from "@growio/shared/components/Tag.vue";

type Model = { email: string; role_id?: number; id?: number };

const props = defineProps({
  modelValue: {
    type: Object as PropType<Model>,
    default: () => ({ email: undefined, role_id: undefined }),
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits({
  close: () => true,
  submit: (_v: Model) => true,
});

const model = ref(clone(props.modelValue));
const roles = ref<MarketplaceAccountRole[]>([]);

const role = ref<MarketplaceAccountRole>();
watch(role, (v) => (model.value.role_id = v?.id), { deep: true });

const isLoading = computed(
  () => props.loading || wait.some([Wait.MARKETPLACE_ACCOUNT_ROLES_FETCH])
);

const fetchRoles = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_ROLES_FETCH);
    roles.value = await apiMarketplaceAccountRolesGetAll();
    role.value = roles.value.find((v) => v.id === model.value.role_id);
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_ROLES_FETCH);
  }
};

fetchRoles();
</script>

<style module>
.row {
  display: flex;
  gap: 8px;
}
</style>
