import { createRouter, createWebHistory } from "vue-router";
import { ensureAccount } from "~/middlewares/ensure-account";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/auth",
      component: () => import("~/pages/auth.vue"),
    },

    {
      path: "/",
      component: () => import("~/layouts/default.vue"),
      beforeEnter: [ensureAccount],
      children: [
        {
          path: "",
          component: () => import("~/pages/dashboard.vue"),
        },
      ],
    },
  ],
});
