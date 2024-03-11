import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { browserslistToTargets } from "lightningcss";
import browserslist from "browserslist";

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      "~": new URL("./src", import.meta.url).pathname,
    },
  },
  css: {
    transformer: "lightningcss",
    lightningcss: {
      targets: browserslistToTargets(browserslist(">= 1%")),
    },
  },
  build: {
    cssMinify: "lightningcss",
  },
});
