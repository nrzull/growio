import { ref } from "vue";

const state = ref(new Set<string>([]));

const start = (v: string) => state.value.add(v);
const end = (v: string) => state.value.delete(v);
const is = (v: string) => state.value.has(v);
const some = (v: string[]) => v.some((vv) => state.value.has(vv));

export const wait = { start, is, some, end };
