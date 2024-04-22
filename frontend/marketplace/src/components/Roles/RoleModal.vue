<template>
  <Modal size="lg" :loading="isLoading" @close="$emit('close')">
    <template v-if="isMarketplaceAccountRole(role)" #heading>
      <span>{{ role.name }}</span> <Tag>Role</Tag>
    </template>
    <template v-else #heading> New Role </template>

    <div :class="$style.rows">
      <div :class="$style.row">
        <TextInput v-model="model.name" placeholder="Name" />
        <TextInput v-model="model.description" placeholder="Description" />
      </div>

      <div :class="[$style.permissions]">
        <Tag
          v-for="permission in permissions"
          :key="permission"
          :class="$style.permission"
          :active="isActive(permission)"
          clickable
          @click="togglePermission(permission)"
        >
          {{ permission }}
        </Tag>
      </div>
    </div>

    <template #footer>
      <Button type="link-neutral" size="md" @click="toggleAllPermissions">
        Toggle all permissions
      </Button>

      <Button size="md" @click="$emit('save', model)">Save</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, computed, ref } from "vue";
import Button from "@growio/shared/components/Button.vue";
import { MarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/types";
import Modal from "@growio/shared/components/Modal.vue";
import { PartialMarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/types";
import { clone } from "remeda";
import TextInput from "@growio/shared/components/TextInput.vue";
import { apiPermissionsGetAll } from "@growio/shared/api/growio/permissions";
import Tag from "@growio/shared/components/Tag.vue";
import { wait, Wait } from "@growio/shared/composables/wait";
import { isMarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/utils";

const props = defineProps({
  role: {
    type: Object as PropType<
      MarketplaceAccountRole | PartialMarketplaceAccountRole
    >,
    required: true,
  },

  loading: {
    type: Boolean,
    default: false,
  },
});

defineEmits({
  close: () => true,
  save: (_v: MarketplaceAccountRole | PartialMarketplaceAccountRole) => true,
});

const isLoading = computed(
  () =>
    props.loading ||
    wait.some([Wait.MARKETPLACE_ACCOUNT_ROLE_PERMISSIONS_FETCH])
);

const model = ref(clone(props.role));

const permissions = ref<string[]>([]);

const isActive = (permission: string) =>
  model.value.permissions?.some((v) => v === permission);

const togglePermission = (permission: string) => {
  if (model.value.permissions?.some((v) => v === permission)) {
    model.value.permissions = model.value.permissions.filter(
      (v) => v !== permission
    );
  } else {
    model.value.permissions = model.value.permissions.concat([permission]);
  }
};

const toggleAllPermissions = () => {
  if (permissions.value.some(isActive)) {
    model.value.permissions = [];
  } else {
    model.value.permissions = permissions.value;
  }
};

const fetchPermissions = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_ROLE_PERMISSIONS_FETCH);
    permissions.value = await apiPermissionsGetAll();
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_ROLE_PERMISSIONS_FETCH);
  }
};

fetchPermissions();
</script>

<style module>
.rows {
  display: grid;
  gap: 24px;
}

.row {
  display: grid;
  gap: 8px;
  grid-template-columns: 1fr 1fr;
}

.permissions {
  display: flex;
  gap: 8px;
  flex-flow: wrap;
}
</style>
