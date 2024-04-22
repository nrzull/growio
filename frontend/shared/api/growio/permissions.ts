import { growio } from "@growio/shared/api/growio";

export const apiPermissionsGetAll = () =>
  growio.get<string[]>("/api/permissions").then((r) => r.data);
