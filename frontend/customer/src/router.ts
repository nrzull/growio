import { createRouter, createWebHistory } from "vue-router";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "",
      component: () => import("~/layouts/Default.vue"),
      children: [
        {
          path: ":payload",
          component: () => import("~/pages/root.vue"),
          children: [
            {
              path: "cart",
              component: () => import("~/pages/cart.vue"),
            },

            {
              path: "",
              component: () => import("~/pages/inventory.vue"),
            },
          ],
        },
      ],
    },
  ],
});
