import axios from "axios";
import { Socket } from "phoenix";

export const growio = axios.create({
  baseURL: import.meta.env.VITE_GROWIO_API,
  withCredentials: true,
});

export const growioWS = new Socket(
  `${import.meta.env.VITE_GROWIO_API_WS}/socket`
);
