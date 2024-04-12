import { growio } from "~/api/growio";
import { MarketplaceAccountEmailInvitation } from "~/api/growio/marketplace_account_email_invitations/types";
import { IdParam } from "~/api/types";

export const apiMarketplaceAccountEmailInvitationsGetAll = () =>
  growio
    .get<MarketplaceAccountEmailInvitation[]>(
      "/api/marketplace_account_email_invitations"
    )
    .then((r) => r.data);

export const apiMarketplaceAccountEmailInvitationsCreate = (params: {
  email: string;
  role_id: IdParam;
}) =>
  growio
    .post("/api/marketplace_account_email_invitations", params)
    .then((r) => r.data);

export const apiMarketplaceAccountEmailInvitationsGetReceived = (params: {
  email: string;
  password: string;
}) =>
  growio
    .get<MarketplaceAccountEmailInvitation>(
      `/api/marketplace_account_email_invitations/${params.email}/${params.password}`
    )
    .then((r) => r.data);

export const apiMarketplaceAccountEmailInvitationsAcceptReceived = (params: {
  email: string;
  password: string;
}) =>
  growio.post(
    `/api/marketplace_account_email_invitations/${params.email}/${params.password}/accept`
  );
