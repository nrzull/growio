import { Account } from "@growio/shared/api/growio/accounts/types";
import { growio } from "@growio/shared/api/growio";

export const apiAccountsGetSelf = () =>
  growio.get<Account>("/api/accounts/self").then((r) => r.data);
