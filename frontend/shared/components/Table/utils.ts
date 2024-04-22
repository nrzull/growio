import { Cell, Header } from "@tanstack/vue-table";

export const prepareSlotName = (accessor: string, suffix = "") =>
  [accessor.replace(/\.+/g, "-"), suffix].filter((v) => v).join("-");

export const getAccessorKey = (target: Cell<any, any> | Header<any, any>) =>
  target.id.split("_").reverse()[0];

export const getCellStyle = (target: Cell<any, any> | Header<any, any>) =>
  (target.column.columnDef.meta as any)?.style || {};

export const getCellInnerBodyStyle = (
  target: Cell<any, any> | Header<any, any>
) => (target.column.columnDef.meta as any)?.innerBodyStyle || {};
