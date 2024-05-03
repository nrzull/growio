import { format } from "date-fns/fp";
import { differenceInCalendarDays } from "date-fns";

export const formatHHMM = format("HH:mm");
export const formatDDMMYY = format("yyyy-MM-dd");

export const formatRelative = (d1: Date) => {
  const diff = differenceInCalendarDays(new Date(), d1);
  return diff === 0 ? "Today" : diff === 1 ? "Yesterday" : formatDDMMYY(d1);
};
