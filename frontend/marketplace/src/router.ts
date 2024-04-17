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
      path: "/invitation/:email/:password",
      component: () => import("~/pages/invitation.vue"),
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
          path: "self",
          children: [
            {
              path: "marketplaces",
              component: () => import("~/pages/self/marketplaces.vue"),
            },

            {
              path: "",
              redirect: "/self/marketplaces",
            },
          ],
        },

        {
          path: "staff",
          component: () => import("~/pages/staff.vue"),
          children: [
            {
              path: "users",
              component: () => import("~/pages/staff/users.vue"),
            },

            {
              path: "roles",
              component: () => import("~/pages/staff/roles.vue"),
            },

            {
              path: "",
              redirect: "/staff/users",
            },
          ],
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
          path: "settings",
          component: () => import("~/pages/settings.vue"),
          children: [
            {
              path: "general",
              component: () => import("~/pages/settings/general.vue"),
            },

            {
              path: "subscription",
              component: () => import("~/pages/settings/subscription.vue"),
            },

            {
              path: "",
              redirect: "/settings/general",
            },
          ],
        },

        {
          path: "markets",
          component: () => import("~/pages/markets.vue"),
        },

        {
          path: "orders",
          component: () => import("~/pages/orders.vue"),
        },

        {
          path: "stats",
          component: () => import("~/pages/stats.vue"),
        },

        {
          path: "support",
          component: () => import("~/pages/support.vue"),
        },

        {
          path: "",
          redirect: "/staff/users",
        },
      ],
    },
  ],
});
