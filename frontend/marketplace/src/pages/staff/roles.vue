<template>
  <PageLoader :loading="isLoading" />

  <RoleModal
    v-if="activeRole"
    :role="activeRole"
    :loading="isLoading"
    @save="saveRole"
    @close="activeRole = undefined"
  />

  <PromiseModal ref="deleteRoleModal">
    <template #heading>Delete role</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <PageShape>
    <template #heading> Roles <Tag v-if="deletedRoles">Deleted</Tag> </template>

    <template #tools>
      <Button size="sm" type="link-neutral" @click="toggleDeletedRoles">
        Toggle deleted roles
      </Button>

      <Button
        size="sm"
        icon="plus"
        :disabled="deletedRoles"
        @click="activeRole = buildPartialMarketplaceAccountRole()"
      >
        Create
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There is no roles' }"
    />
    <Table
      v-else
      :clickable="!deletedRoles"
      :table="table"
      @click:row="handleClickRole"
    >
      <template #actions="{ ctx }">
        <Icon
          v-if="!deletedRoles"
          clickable
          value="trashCircle"
          @click.stop="deleteRole(ctx.row.original)"
        />
      </template>
    </Table>
  </PageShape>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import {
  Row,
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import PageShape from "@growio/shared/components/PageShape.vue";
import Button from "@growio/shared/components/Button.vue";
import { MarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/types";
import { wait, Wait } from "@growio/shared/composables/wait";
import {
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_CREATED,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_CREATED_FAILURE,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_DELETED,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_DELETED_FAILURE,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_UPDATED,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_UPDATED_FAILURE,
} from "@growio/shared/composables/notifications/constants";
import {
  apiMarketplaceAccountRolesGetAll,
  apiMarketplaceAccountRolesUpdate,
  apiMarketplaceAccountRolesDelete,
} from "@growio/shared/api/growio/marketplace_account_roles";
import Table from "@growio/shared/components/Table.vue";
import RoleModal from "~/components/Roles/RoleModal.vue";
import {
  buildPartialMarketplaceAccountRole,
  isMarketplaceAccountRole,
} from "@growio/shared/api/growio/marketplace_account_roles/utils";
import { PartialMarketplaceAccountRole } from "@growio/shared/api/growio/marketplace_account_roles/types";
import { apiMarketplaceAccountRolesCreate } from "@growio/shared/api/growio/marketplace_account_roles";
import {
  addSuccessNotification,
  addErrorNotification,
} from "@growio/shared/composables/notifications";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import Icon from "@growio/shared/components/Icon.vue";
import Tag from "@growio/shared/components/Tag.vue";

const roles = ref<MarketplaceAccountRole[]>([]);
const deletedRoles = ref(false);
const activeRole = ref<
  MarketplaceAccountRole | PartialMarketplaceAccountRole
>();

const deleteRoleModal = ref<InstanceType<typeof PromiseModal>>();

const columnHelper = createColumnHelper<MarketplaceAccountRole>();

const columns = ref([
  columnHelper.accessor("name", {
    cell: (info) => info.getValue(),
    header: () => "Name",
  }),

  columnHelper.accessor("description", {
    cell: (info) => info.getValue(),
    header: () => "Description",
  }),

  columnHelper.display({
    id: "actions",
    cell: (info) => info.getValue(),
    meta: {
      style: {
        width: "0",
      },
    },
  }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return roles.value;
  },

  get columns() {
    return columns.value;
  },
});

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ACCOUNT_ROLES_FETCH,
    Wait.MARKETPLACE_ACCOUNT_ROLE_CREATE,
    Wait.MARKETPLACE_ACCOUNT_ROLE_UPDATE,
    Wait.MARKETPLACE_ACCOUNT_ROLE_DELETE,
  ])
);

const isEmpty = computed(() => !isLoading.value && !roles.value.length);

const handleClickRole = (row: Row<MarketplaceAccountRole>) => {
  activeRole.value = row.original;
};

const saveRole = async (
  role: MarketplaceAccountRole | PartialMarketplaceAccountRole
) => {
  if (isMarketplaceAccountRole(role)) {
    try {
      wait.start(Wait.MARKETPLACE_ACCOUNT_ROLE_UPDATE);
      await apiMarketplaceAccountRolesUpdate(role);
      addSuccessNotification({
        text: NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_UPDATED,
      });
    } catch (e) {
      console.error(e);
      addErrorNotification({
        text: NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_UPDATED_FAILURE,
      });
    } finally {
      wait.end(Wait.MARKETPLACE_ACCOUNT_ROLE_UPDATE);
    }
  } else {
    try {
      wait.start(Wait.MARKETPLACE_ACCOUNT_ROLE_CREATE);
      await apiMarketplaceAccountRolesCreate(role);
      addSuccessNotification({
        text: NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_CREATED,
      });
    } catch (e) {
      console.error(e);
      addErrorNotification({
        text: NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_CREATED_FAILURE,
      });
    } finally {
      wait.end(Wait.MARKETPLACE_ACCOUNT_ROLE_CREATE);
    }
  }

  activeRole.value = undefined;
  await fetchRoles();
};

const deleteRole = async (role: MarketplaceAccountRole) => {
  try {
    await deleteRoleModal.value?.confirm();
  } catch {
    return;
  }

  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_ROLE_DELETE);
    await apiMarketplaceAccountRolesDelete(role);
    await fetchRoles();
    addSuccessNotification({
      text: NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_DELETED,
    });
  } catch (e) {
    console.error(e);
    addErrorNotification({
      text: NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_DELETED_FAILURE,
    });
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_ROLE_DELETE);
  }
};

const toggleDeletedRoles = () => {
  deletedRoles.value = !deletedRoles.value;
  fetchRoles();
};

const fetchRoles = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ACCOUNT_ROLES_FETCH);
    roles.value = await apiMarketplaceAccountRolesGetAll({
      deleted_at: deletedRoles.value,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_ROLES_FETCH);
  }
};

fetchRoles();
</script>
