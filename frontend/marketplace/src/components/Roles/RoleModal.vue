<template>
  <Modal size="lg" @close="$emit('close')">
    <template #heading>{{ role.name || "New Role" }}</template>

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
      <Button type="neutral" size="md" @click="toggleAllPermissions">
        Toggle all permissions
      </Button>

      <Button size="md" @click="$emit('save', model)">Save</Button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { PropType, ref } from "vue";
import Button from "~/components/Button.vue";
import { MarketplaceAccountRole } from "~/api/growio/marketplace_account_roles/types";
import Modal from "~/components/Modal.vue";
import { PartialMarketplaceAccountRole } from "~/components/Roles/types";
import { clone } from "remeda";
import TextInput from "~/components/TextInput.vue";
import { apiPermissionsGetAll } from "~/api/growio/permissions";
import Tag from "~/components/Tag.vue";

const props = defineProps({
  role: {
    type: Object as PropType<
      MarketplaceAccountRole | PartialMarketplaceAccountRole
    >,
    required: true,
  },
});

defineEmits({
  close: () => true,
  save: (_v: MarketplaceAccountRole | PartialMarketplaceAccountRole) => true,
});

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

apiPermissionsGetAll().then((r) => (permissions.value = r));
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
