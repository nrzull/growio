import { JSONPath } from "jsonpath-plus";
import { isPlainObject } from "remeda";
import { PropType } from "vue";
import { Item, ItemComplex, ItemPrimitive } from "~/components/Menu/types";

export const itemsProp = {
  type: Array as PropType<Item[]>,
  default: () => [],
};

export const isPrimitive = (v: unknown): v is ItemPrimitive =>
  !isPlainObject(v);

export const isComplex = (v: unknown): v is ItemComplex => isPlainObject(v);

export const getLabel = (v: Item, path: string) => {
  if (isPrimitive(v)) {
    return v;
  }

  const [result] = JSONPath({ json: v, path });
  return result;
};

export const getKey = (v: Item, path: string, fallback?: any) => {
  if (isPrimitive(v)) {
    return v || fallback;
  }

  const [result] = JSONPath({ json: v, path });
  return result;
};

export const getChildren = (v: Item, path: string) => {
  if (isPrimitive(v)) {
    return;
  }

  const [result] = JSONPath({ json: v, path });
  return result;
};
