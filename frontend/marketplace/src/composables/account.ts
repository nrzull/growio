import { ref } from "vue";
import { Account } from "~/api/growio/accounts/types";
import { apiAccountsGetSelf } from "~/api/growio/accounts";

export const account = ref<Account>();

export const fetchAccount = async () => {
  try {
    account.value = await apiAccountsGetSelf();
  } catch (e) {
    console.error(e);
  }
};
