<template>
  <template v-for="row in table.getRowModel().rows" :key="row.id">
    <tr @click="clickable ? $emit('click:row', row) : null">
      <td
        v-for="(cell, i) in row.getVisibleCells()"
        :key="cell.id"
        :style="{
          ...getCellStyle(cell),
          paddingLeft: i === 0 ? `${16 * level}px` : undefined,
        }"
      >
        <div :class="$style.tdBody" :style="getCellInnerBodyStyle(cell)">
          <Button
            v-if="expanderPath && expanderPath === getAccessorKey(cell)"
            size="sm"
            icon="chevronDown"
            type="link-neutral"
            :class="{ [$style.hidden]: !hasChildren(row) }"
            @click.stop="expanded[row.id] = !expanded[row.id]"
          >
          </Button>

          <slot
            :name="prepareSlotName(getAccessorKey(cell))"
            v-bind="{ ctx: cell }"
          >
            <FlexRender
              :render="cell.column.columnDef.cell"
              :props="cell.getContext()"
            />
          </slot>
        </div>
      </td>
    </tr>

    <Rows
      v-if="hasChildren(row) && expanded[row.id]"
      v-bind="$props"
      :level="level + 1"
      :table="createTable(row.original[childrenPath])"
      @click:row="$emit('click:row', $event)"
    >
      <template v-for="sl in Object.keys($slots)" #[sl]="{ ...params }">
        <slot :name="sl" v-bind="{ ...params }"></slot>
      </template>
    </Rows>
  </template>
</template>

<script setup lang="ts">
import {
  Row,
  getCoreRowModel,
  useVueTable,
  FlexRender,
} from "@tanstack/vue-table";
import { PropType, ref } from "vue";
import {
  prepareSlotName,
  getAccessorKey,
  getCellStyle,
  getCellInnerBodyStyle,
} from "@growio/shared/components/Table/utils";
import Button from "@growio/shared/components/Button.vue";

defineOptions({ name: "Rows", inheritAttrs: false });

const props = defineProps({
  table: {
    type: Object as PropType<ReturnType<typeof useVueTable<any>>>,
    required: true,
  },

  columns: {
    type: Array as PropType<any>,
    default: () => [],
  },

  clickable: {
    type: Boolean,
    default: false,
  },

  expanderPath: {
    type: String,
    default: undefined,
  },

  childrenPath: {
    type: String,
    default: undefined,
  },

  level: {
    type: Number,
    default: 1,
  },
});

defineEmits({
  "click:row": (_v: Row<any>) => true,
});

const expanded = ref<Record<string, boolean>>({});

const createTable = (data: Array<any>) =>
  useVueTable({
    getCoreRowModel: getCoreRowModel(),

    get data() {
      return data;
    },

    get columns() {
      return props.columns;
    },
  });

const hasChildren = (row: Row<any>) =>
  !!(props.childrenPath && row.original[props.childrenPath]?.length);
</script>

<style module>
.hidden {
  visibility: hidden;
}

.tdBody {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
</style>
