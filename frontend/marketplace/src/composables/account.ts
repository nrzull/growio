import { ref } from "vue";
import { Account } from "@growio/shared/api/growio/accounts/types";
import { apiAccountsGetSelf } from "@growio/shared/api/growio/accounts";

export const account = ref<Account>();

export const fetchAccount = async () => {
  try {
    account.value = await apiAccountsGetSelf();
  } catch (e) {
    console.error(e);
  }
};
