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
          component: () => import("~/pages/_payload.vue"),
          children: [
            {
              path: "categories",
              component: () => import("~/pages/_payload/categories.vue"),
              children: [
                {
                  path: ":categoryId?",
                  component: () =>
                    import("~/pages/_payload/categories/_categoryId.vue"),
                },
              ],
            },

            {
              path: "cart",
              component: () => import("~/pages/_payload/cart.vue"),
            },

            {
              path: "",
              redirect: (v) => `${v.params.payload}/categories`,
            },
          ],
        },
      ],
    },
  ],
});
