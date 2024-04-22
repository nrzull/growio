import axios from "axios";

export const growio = axios.create({
  baseURL: import.meta.env.VITE_GROWIO_API,
  withCredentials: true,
});
