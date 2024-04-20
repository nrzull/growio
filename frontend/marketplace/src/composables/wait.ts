import { ref } from "vue";

const state = ref(new Set<string | number>([]));
const start = (v: string | number) => state.value.add(v);
const end = (v: string | number) => state.value.delete(v);
const is = (v: string | number) => state.value.has(v);
const some = (v: Array<string | number>) => v.some((vv) => state.value.has(vv));

export const wait = { start, is, some, end };

export enum Wait {
  MARKETPLACE_ACCOUNT_EMAIL_INVITATIONS_FETCH,
  MARKETPLACE_ACCOUNT_EMAIL_INVITATION_FETCH,
  MARKETPLACE_ACCOUNT_EMAIL_INVITATION_CREATE,
  MARKETPLACE_ACCOUNT_EMAIL_INVITATION_ACCEPT,
  MARKETPLACE_ACCOUNT_EMAIL_INVITATION_DELETE,
  MARKETPLACE_ACCOUNT_ROLES_FETCH,
  MARKETPLACE_ACCOUNT_ROLE_DELETE,
  MARKETPLACE_ACCOUNT_ROLE_CREATE,
  MARKETPLACE_ACCOUNT_ROLE_UPDATE,
  MARKETPLACE_ACCOUNT_ROLE_PERMISSIONS_FETCH,
  MARKETPLACE_ACCOUNTS_FETCH,
  MARKETPLACE_ACCOUNT_UPDATE,
  MARKETPLACE_ACCOUNT_BLOCK,
  MARKETPLACE_ACCOUNT_SWITCH,
  MARKETPLACE_ITEM_CATEGORIES_FETCH,
  MARKETPLACE_ITEM_CATEGORY_FETCH,
  MARKETPLACE_ITEM_CATEGORY_CREATE,
  MARKETPLACE_ITEM_CATEGORY_UPDATE,
  MARKETPLACE_ITEM_CATEGORY_DELETE,
  MARKETPLACE_ITEMS_FETCH,
  MARKETPLACE_ITEM_CREATE,
  MARKETPLACE_ITEM_UPDATE,
  MARKETPLACE_ITEM_DELETE,
  MARKETPLACE_ITEM_ASSETS_FETCH,
  MARKETPLACE_ITEM_ASSET_CREATE,
  MARKETPLACE_ITEM_ASSET_DELETE,
  MARKETPLACE_ITEMS_TREE_FETCH,
  MARKETPLACE_CREATE,
  MARKETPLACE_UPDATE,
  MARKETPLACE_MARKETS_FETCH,
  MARKETPLACE_MARKET_FETCH,
  MARKETPLACE_MARKET_CREATE,
  MARKETPLACE_MARKET_UPDATE,
  MARKETPLACE_MARKET_DELETE,
  MARKETPLACE_MARKET_ITEMS_FETCH,
  MARKETPLACE_MARKET_ITEM_CREATE,
  MARKETPLACE_MARKET_ITEM_UPDATE,
  MARKETPLACE_MARKET_ITEM_DELETE,
  MARKETPLACE_MARKET_INTEGRATIONS_FETCH,
  MARKETPLACE_MARKET_TELEGRAM_BOT_FETCH,
  MARKETPLACE_MARKET_TELEGRAM_BOT_CREATE,
  MARKETPLACE_MARKET_TELEGRAM_BOT_UPDATE,
  MARKETPLACE_MARKET_TELEGRAM_BOT_DELETE,
}
