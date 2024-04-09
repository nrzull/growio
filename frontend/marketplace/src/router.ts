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
      component: () => import("~/layouts/Default.vue"),
      beforeEnter: [
        ensureAccount,
        ensureMarketplaceAccounts,
        fetchActiveMarketplaceAccount,
      ],
      children: [
        {
          path: "users",
          component: () => import("~/pages/users.vue"),
        },

        {
          path: "roles",
          component: () => import("~/pages/roles.vue"),
        },

        {
          path: "inventory",
          component: () => import("~/pages/inventory.vue"),
          children: [
            {
              path: "items",
              component: () => import("~/pages/inventory/items.vue"),
            },

            {
              path: "categories",
              component: () => import("~/pages/inventory/categories.vue"),
            },

            {
              path: "",
              redirect: "/inventory/items",
            },
          ],
        },

        {
          path: "",
          redirect: "/users",
        },
      ],
    },
  ],
});
