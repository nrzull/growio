import { IdParam } from "@growio/shared/api/types";
import { ref } from "vue";

export type NotificationItem = {
  id: IdParam;
  type: "success" | "error" | "info";
  text: string;
  closable?: boolean;
  lifetime?: number;
};

export const state = ref<NotificationItem[]>([]);

const defaults = () => ({ lifetime: 10000 });

const buildNotification = (
  params: Omit<NotificationItem, "id">
): NotificationItem => ({
  ...defaults(),
  id: Date.now().toString(),
  ...params,
});

const addNotification = (params: Omit<NotificationItem, "id">) => {
  const notification = buildNotification(params);

  state.value.push(notification);

  setTimeout(
    () => (state.value = state.value.filter((v) => v.id !== notification.id)),
    notification.lifetime
  );
};

export const addSuccessNotification = (
  params: Omit<NotificationItem, "id" | "type">
) => addNotification({ ...params, type: "success" });

export const addErrorNotification = (
  params: Omit<NotificationItem, "id" | "type">
) => addNotification({ ...params, type: "error" });

export const addInfoNotification = (
  params: Omit<NotificationItem, "id" | "type">
) => addNotification({ ...params, type: "info" });
