export type Item = ItemPrimitive | ItemComplex;
export type ItemPrimitive = undefined | null | string | number;
export type ItemComplex = Record<any, any>;
