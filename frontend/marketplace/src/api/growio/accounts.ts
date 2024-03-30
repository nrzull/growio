import { Account } from "~/api/growio/accounts/types";
import { growio } from "~/api/growio";

export const apiAccountsGetSelf = () =>
  growio.get<Account>("/accounts/self").then((r) => r.data);
