<template>
  <PageLoader :loading="isLoading" />

  <RoleModal
    v-if="activeRole"
    :role="activeRole"
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
    <template #heading>
      Roles <template v-if="deletedRoles">(Deleted)</template>
    </template>

    <template #tools>
      <Button size="sm" type="link-neutral" @click="toggleDeletedRoles">
        Toggle deleted roles
      </Button>

      <Button
        size="sm"
        :icon="plusSvg"
        :disabled="deletedRoles"
        @click="activeRole = buildMarketplaceAccountRole()"
      >
        Create
      </Button>
    </template>

    <Notification
      v-if="isEmpty"
      :model-value="{ type: 'info', text: 'There are no roles' }"
    />
    <Table
      v-else
      :clickable="!deletedRoles"
      :table="table"
      @click:row="handleClickRole"
    >
      <template #actions="{ ctx }">
        <div
          v-if="!deletedRoles"
          :class="$style.trash"
          v-html="trashCircleSvg"
          @click.stop="deleteRole(ctx.row.original)"
        ></div>
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
import PageLoader from "~/components/PageLoader.vue";
import PageShape from "~/components/PageShape.vue";
import Button from "~/components/Button.vue";
import plusSvg from "~/assets/plus.svg";
import { MarketplaceAccountRole } from "~/api/growio/marketplace_account_roles/types";
import { wait, Wait } from "~/composables/wait";
import {
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_CREATED,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_CREATED_FAILURE,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_DELETED,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_DELETED_FAILURE,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_UPDATED,
  NOTIFICATION_MARKETPLACE_ACCOUNT_ROLE_UPDATED_FAILURE,
} from "~/composables/notifications/constants";
import {
  apiMarketplaceAccountRolesGetAll,
  apiMarketplaceAccountRolesUpdate,
  apiMarketplaceAccountRolesDelete,
} from "~/api/growio/marketplace_account_roles";
import Table from "~/components/Table.vue";
import RoleModal from "~/components/Roles/RoleModal.vue";
import {
  buildMarketplaceAccountRole,
  isMarketplaceAccountRole,
} from "~/components/Roles/utils";
import { PartialMarketplaceAccountRole } from "~/components/Roles/types";
import { apiMarketplaceAccountRolesCreate } from "~/api/growio/marketplace_account_roles";
import trashCircleSvg from "~/assets/trash-circle.svg?raw";
import {
  addSuccessNotification,
  addErrorNotification,
} from "~/composables/notifications";
import Notification from "~/components/Notifications/Notification.vue";
import PromiseModal from "~/components/PromiseModal.vue";

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

<style module>
.trash {
  height: 32px;
  width: 32px;
  cursor: pointer;
}

.trash:hover * {
  fill: var(--color-primary);
}
</style>
