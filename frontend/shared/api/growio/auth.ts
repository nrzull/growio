import { growio } from "@growio/shared/api/growio";

export const apiAuthSendEmail = (params: { email: string }) =>
  growio
    .post<{ email: string; password?: string; expiredAt: string }>(
      "/api/auth/email",
      params
    )
    .then((r) => r.data);

export const apiAuthSendEmailOtp = (params: {
  email: string;
  password: string;
}) => growio.post("/api/auth/email/otp", params);

export const apiAuthSignout = () => growio.get("/api/auth/signout");

export const apiAuthHealthcheck = () => growio.get("/api/auth/healthcheck");
