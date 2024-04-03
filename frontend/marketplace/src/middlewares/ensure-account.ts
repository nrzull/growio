import { account } from "~/composables/account";
import { RouteLocationNormalized } from "vue-router";
import { fetchAccount } from "~/composables/account";

export const ensureAccount = async (to: RouteLocationNormalized) => {
  await fetchAccount();

  if (!account.value) {
    return {
      path: "/auth",
      query: { to: to.fullPath },
    };
  }
};
