<template>
  <Shape paddingless type="secondary" :class="$style.shape">
    <table
      v-if="table"
      :class="[
        $style.table,
        { [$style.clickable]: clickable, [$style.headless]: headless },
      ]"
    >
      <thead
        v-if="!headless && table.getHeaderGroups().length"
        :class="$style.head"
      >
        <tr
          v-for="headerGroup in table.getHeaderGroups()"
          :key="headerGroup.id"
        >
          <th
            v-for="header in headerGroup.headers"
            :key="header.id"
            :style="getCellStyle(header)"
            :colSpan="header.colSpan"
          >
            <slot
              v-if="!header.isPlaceholder"
              :name="prepareSlotName(getAccessorKey(header), 'header')"
              v-bind="{ ctx: header }"
            >
              <FlexRender
                :render="header.column.columnDef.header"
                :props="header.getContext()"
              />
            </slot>
          </th>
        </tr>
      </thead>

      <tbody v-if="table.getRowModel().rows.length" :class="$style.body">
        <Rows
          :table
          :children-path
          :clickable
          :expander-path
          @click:row="$emit('click:row', $event)"
        >
          <template v-for="sl in Object.keys($slots)" #[sl]="{ ...params }">
            <slot :name="sl" v-bind="{ ...params }"></slot>
          </template>
        </Rows>
      </tbody>

      <tfoot v-if="table.getFooterGroups().length">
        <tr
          v-for="footerGroup in table.getFooterGroups()"
          :key="footerGroup.id"
        >
          <th
            v-for="header in footerGroup.headers"
            :key="header.id"
            :style="getCellStyle(header)"
            :colSpan="header.colSpan"
          >
            <slot
              v-if="!header.isPlaceholder"
              :name="prepareSlotName(getAccessorKey(header), 'footer')"
              v-bind="{ ctx: header }"
            >
              <FlexRender
                :render="header.column.columnDef.footer"
                :props="header.getContext()"
              />
            </slot>
          </th>
        </tr>
      </tfoot>
    </table>
  </Shape>
</template>

<script setup lang="ts">
import { PropType } from "vue";
import Shape from "~/components/Shape.vue";
import { useVueTable, FlexRender, Row } from "@tanstack/vue-table";
import Rows from "~/components/Table/Rows.vue";
import {
  prepareSlotName,
  getAccessorKey,
  getCellStyle,
} from "~/components/Table/utils";

defineProps({
  table: {
    type: Object as PropType<ReturnType<typeof useVueTable<any>>>,
    default: undefined,
  },

  headless: {
    type: Boolean,
    default: false,
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
});

defineEmits({
  "click:row": (_v: Row<any>) => true,
});
</script>

<style module>
.shape {
  padding: 8px 0 !important;
}

.table {
  border-collapse: collapse;
  width: 100%;
}

.head th {
  padding: 16px;
  text-align: left;
  font-size: 14px;
  font-weight: normal;
}

.body td {
  padding: 16px;
}

.table.headless .body tr:nth-child(even) td {
  background-color: rgba(255, 255, 255, 0.8);
}

.table:not(.headless) .body tr:nth-child(odd) td {
  background-color: rgba(255, 255, 255, 0.8);
}

.table.clickable .body td {
  cursor: pointer;
  user-select: none;
}

.table.clickable .body tr:hover td {
  box-shadow: inset 0 1px 0 var(--color-primary-300),
    inset 0 -1px 0 var(--color-primary-300);
  background-color: var(--color-primary-100);
}
</style>
