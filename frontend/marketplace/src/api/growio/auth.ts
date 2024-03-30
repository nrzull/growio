import { growio } from "~/api/growio";

export const apiAuthSendEmail = (params: { email: string }) =>
  growio
    .post<{ email: string; password?: string; expiredAt: string }>(
      "/auth/email",
      params
    )
    .then((r) => r.data);

export const apiAuthSendEmailOtp = (params: {
  email: string;
  password: string;
}) => growio.post("/auth/email/otp", params);

export const apiAuthSignout = () => growio.get("/auth/signout");

export const apiAuthHealthcheck = () => growio.get("/auth/healthcheck");
