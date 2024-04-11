import { ref } from "vue";

const state = ref(new Set<string | number>([]));
const start = (v: string | number) => state.value.add(v);
const end = (v: string | number) => state.value.delete(v);
const is = (v: string | number) => state.value.has(v);
const some = (v: Array<string | number>) => v.some((vv) => state.value.has(vv));

export const wait = { start, is, some, end };

export enum Wait {
  MARKETPLACE_ACCOUNT_EMAIL_INVITATIONS_FETCH,
  MARKETPLACE_ACCOUNT_ROLES_FETCH,
  MARKETPLACE_ACCOUNT_ROLE_DELETE,
  MARKETPLACE_ACCOUNT_ROLE_CREATE,
  MARKETPLACE_ACCOUNT_ROLE_UPDATE,
  MARKETPLACE_ACCOUNTS_FETCH,
  MARKETPLACE_ITEM_CATEGORIES_FETCH,
  MARKETPLACE_ITEM_CATEGORY_FETCH,
  MARKETPLACE_ITEM_CATEGORY_CREATE,
  MARKETPLACE_ITEM_CATEGORY_UPDATE,
  MARKETPLACE_ITEM_CATEGORY_DELETE,
  MARKETPLACE_ITEMS_FETCH,
  MARKETPLACE_ITEM_CREATE,
  MARKETPLACE_ITEM_UPDATE,
  MARKETPLACE_ITEM_DELETE,
}
