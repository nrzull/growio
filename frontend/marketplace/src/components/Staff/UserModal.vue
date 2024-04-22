<template>
  <Modal :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceAccount(modelValue)" #heading>
      <span>{{ modelValue.account.email }}</span> <Tag>User</Tag>
    </template>
    <template v-else #heading> Create User </template>

    <div :class="$style.row">
      <TextInput
        v-model="model.account.email"
        :readonly="readonly || isMarketplaceAccount(modelValue)"
        placeholder="Email"
      />
      <SelectInput
        v-model="model.role"
        :readonly
        placeholder="Role"
        track-by="id"
        label-path="name"
        :items="roles"
      />
    </div>

    <template #footer>
      <Button
        size="md"
        @click="readonly ? $emit('close') : $emit('submit', model)"
      >
        Submit
      </Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, ref, computed } from "vue";
import Modal from "@growio/shared/components/Modal.vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import SelectInput from "@growio/shared/components/SelectInput.vue";
import Button from "@growio/shared/components/Button.vue";
import { apiMarketplaceAccountRolesGetAll } from "@growio/shared/api/growio/marketplace_account_roles";
import { MarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/types";
import { clone } from "remeda";
import { wait, Wait } from "@growio/shared/composables/wait";
import Tag from "@growio/shared/components/Tag.vue";
import { MarketplaceAccount } from "@growio/shared/api/growio/marketplace_accounts/types";
import { isMarketplaceAccount } from "@growio/shared/api/growio/marketplace_accounts/utils";

const props = defineProps({
  modelValue: {
    type: Object as PropType<MarketplaceAccount>,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },

  readonly: {
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
