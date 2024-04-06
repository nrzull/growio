<template>
  <PageLoader v-if="isLoading" />

  <RoleModal
    v-if="activeRole"
    :role="activeRole"
    @save="saveRole"
    @close="activeRole = undefined"
  />

  <PageShape>
    <template #heading
      >Roles <template v-if="deletedRoles">(Deleted)</template>
    </template>

    <template #tools>
      <Button size="sm" type="neutral" @click="toggleDeletedRoles">
        Toggle deleted roles
      </Button>

      <Button
        size="sm"
        :icon="plusSvg"
        @click="activeRole = buildMarketplaceAccountRole()"
      >
        Create
      </Button>
    </template>

    <Table clickable :table="table" @click:row="handleClickRole">
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
import { wait } from "~/composables/wait";
import { WAIT_MARKETPLACE_ACCOUNT_ROLES_FETCH } from "~/constants";
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

const roles = ref<MarketplaceAccountRole[]>([]);
const deletedRoles = ref(false);
const activeRole = ref<
  MarketplaceAccountRole | PartialMarketplaceAccountRole
>();

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

  columnHelper.accessor("actions" as any, {
    cell: (info) => info.getValue(),
    header: () => "",
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
  wait.some([WAIT_MARKETPLACE_ACCOUNT_ROLES_FETCH])
);

const handleClickRole = (row: Row<MarketplaceAccountRole>) => {
  activeRole.value = row.original;
};

const saveRole = async (
  role: MarketplaceAccountRole | PartialMarketplaceAccountRole
) => {
  if (isMarketplaceAccountRole(role)) {
    await apiMarketplaceAccountRolesUpdate(role);
  } else {
    await apiMarketplaceAccountRolesCreate(role);
  }

  activeRole.value = undefined;
  await fetchRoles();
};

const deleteRole = async (role: MarketplaceAccountRole) => {
  await apiMarketplaceAccountRolesDelete(role);
  await fetchRoles();
};

const toggleDeletedRoles = () => {
  deletedRoles.value = !deletedRoles.value;
  fetchRoles();
};

const fetchRoles = async () => {
  try {
    wait.start(WAIT_MARKETPLACE_ACCOUNT_ROLES_FETCH);
    roles.value = await apiMarketplaceAccountRolesGetAll({
      deleted_at: deletedRoles.value,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(WAIT_MARKETPLACE_ACCOUNT_ROLES_FETCH);
  }
};

fetchRoles();
</script>

<style module>
.trash {
  height: 32px;
  width: 32px;
}

.trash:hover * {
  fill: var(--color-primary);
}
</style>
