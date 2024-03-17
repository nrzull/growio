import { apiAccountsGetSelf } from "~/api/growio";
import { account } from "~/composables/account";
import { RouteLocationNormalized } from "vue-router";

export const ensureAccount = async (to: RouteLocationNormalized) => {
  if (account.value) {
    return;
  }

  try {
    account.value = await apiAccountsGetSelf();
  } catch (e) {
    console.error(e);

    return {
      path: "/auth",
      query: { to: to.fullPath },
    };
  }
};
