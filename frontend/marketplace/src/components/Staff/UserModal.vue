<template>
  <Modal @close="$emit('close')" :loading="isLoading">
    <template #heading v-if="isMarketplaceAccount(modelValue)">
      <span>{{ modelValue.account.email }}</span> <Tag>User</Tag>
    </template>
    <template #heading v-else> Create User </template>

    <div :class="$style.row">
      <TextInput
        :readonly="isMarketplaceAccount(modelValue)"
        v-model="model.account.email"
        placeholder="Email"
      />
      <SelectInput
        v-model="model.role"
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
import { PropType, ref, computed } from "vue";
import Modal from "~/components/Modal.vue";
import TextInput from "~/components/TextInput.vue";
import SelectInput from "~/components/SelectInput.vue";
import Button from "~/components/Button.vue";
import { apiMarketplaceAccountRolesGetAll } from "~/api/growio/marketplace_account_roles";
import { MarketplaceAccountRole } from "~/api/growio/marketplace_account_roles/types";
import { clone } from "remeda";
import { wait, Wait } from "~/composables/wait";
import Tag from "~/components/Tag.vue";
import { MarketplaceAccount } from "~/api/growio/marketplace_accounts/types";
import { isMarketplaceAccount } from "~/api/growio/marketplace_accounts/utils";

const props = defineProps({
  modelValue: {
    type: Object as PropType<MarketplaceAccount>,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits({
  close: () => true,
  submit: (_v: MarketplaceAccount) => true,
});

const model = ref(clone(props.modelValue));
const roles = ref<MarketplaceAccountRole[]>([]);

const isLoading = computed(
  () => props.loading || wait.some([Wait.MARKETPLACE_ACCOUNT_ROLES_FETCH])
);

const fetchRoles = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_ROLES_FETCH);
    roles.value = await apiMarketplaceAccountRolesGetAll();
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
