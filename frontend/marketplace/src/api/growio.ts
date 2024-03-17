import axios from "axios";
import { AccountRaw, MarketplaceAccountRaw } from "~/api/growio/types";

export const api = axios.create({
  baseURL: import.meta.env.VITE_GROWIO_API,
  withCredentials: true,
});

export const apiAuthSendEmail = (params: { email: string }) =>
  api
    .post<{ email: string; password?: string; expiredAt: string }>(
      "/auth/email",
      params
    )
    .then((r) => r.data);

export const apiAuthSendEmailOtp = (params: {
  email: string;
  password: string;
}) => api.post("/auth/email/otp", params);

export const apiAuthSignout = () => api.get("/auth/signout");

export const apiAuthHealthcheck = () => api.get("/auth/healthcheck");

export const apiAccountsGetSelf = () =>
  api.get<AccountRaw>("/accounts/self").then((r) => r.data);

export const apiMarketplaceAccountsGetSelf = () =>
  api
    .get<MarketplaceAccountRaw[]>("/marketplace_accounts/self")
    .then((r) => r.data);
