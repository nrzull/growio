import { createRouter, createWebHistory } from "vue-router";
import { ensureAccount } from "~/middlewares/ensure-account";
import { ensureMarketplaceAccounts } from "~/middlewares/ensure-marketplace-accounts";
import { fetchActiveMarketplaceAccount } from "~/composables/marketplace-accounts";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/auth",
      component: () => import("~/pages/auth.vue"),
    },

    {
      path: "/setup",
      beforeEnter: [ensureAccount],
      component: () => import("~/pages/setup.vue"),
    },

    {
      path: "/",
      component: () => import("~/layouts/default.vue"),
      beforeEnter: [
        ensureAccount,
        ensureMarketplaceAccounts,
        fetchActiveMarketplaceAccount,
      ],
      children: [
        {
          path: "",
          component: () => import("~/pages/dashboard.vue"),
        },
      ],
    },
  ],
});