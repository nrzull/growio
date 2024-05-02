// https://github.com/vuejs/language-tools/blob/master/packages/component-type-helpers/index.d.ts#L24
export type ComponentExposed<T> = T extends new (...angs: any) => infer E
  ? E
  : T extends (
        props: any,
        ctx: any,
        expose: (exposed: infer E) => any,
        ...args: any
      ) => any
    ? NonNullable<E>
    : {};
