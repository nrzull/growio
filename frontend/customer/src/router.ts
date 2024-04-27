import { createRouter, createWebHistory } from "vue-router";
import { ensureSomeStatus } from "~/middlewares/ensureStatus";
import { payload } from "~/composables/payload";

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
              beforeEnter: [
                (to) => ensureSomeStatus(["init"], `/${to.params.payload}`),
              ],
              component: () => import("~/pages/_payload/categories.vue"),
              children: [
                {
                  path: ":categoryId?",
                  children: [
                    {
                      path: "items/:itemId",
                      component: () =>
                        import(
                          "~/pages/_payload/categories/_categoryId/_itemId.vue"
                        ),
                    },

                    {
                      path: "",
                      component: () =>
                        import("~/pages/_payload/categories/_categoryId.vue"),
                    },
                  ],
                },
              ],
            },

            {
              path: "cart",
              beforeEnter: [
                (to) => ensureSomeStatus(["init"], `/${to.params.payload}`),
              ],
              component: () => import("~/pages/_payload/cart.vue"),
            },

            {
              path: "status",
              beforeEnter: [
                (to) =>
                  ensureSomeStatus(
                    ["need_payment", "done", "cancelled"],
                    `/${to.params.payload}`
                  ),
              ],
              component: () => import("~/pages/_payload/status.vue"),
            },

            {
              path: "",
              redirect: ({ params }) =>
                payload.value.order.status === "init"
                  ? `${params.payload}/categories`
                  : `${params.payload}/status`,
            },
          ],
        },
      ],
    },
  ],
});
