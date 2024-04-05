<template>
  <Modal @close="$emit('close')">
    <template #heading>Invite User</template>

    <div :class="$style.row">
      <TextInput placeholder="Email" v-model="email" />
      <SelectInput
        placeholder="Role"
        track-by="id"
        label-path="name"
        v-model="role"
        :items="roles"
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
import { apiMarketplaceAccountRolesGetAll } from "~/api/growio/marketplace_account_roles";
import { MarketplaceAccountRole } from "~/api/growio/types";
import { apiMarketplaceAccountEmailInvitationsCreate } from "~/api/growio/marketplace_account_email_invitations";

const email = ref();
const role = ref<MarketplaceAccountRole>();
const roles = ref<MarketplaceAccountRole[]>([]);

const emit = defineEmits(["close"]);

apiMarketplaceAccountRolesGetAll().then((r) => (roles.value = r));

const submit = async () => {
  await apiMarketplaceAccountEmailInvitationsCreate({
    email: email.value,
    role_id: role.value?.id,
  });

  emit("close");
};
</script>

<style module>
.row {
  display: flex;
  gap: 8px;
}
</style>
