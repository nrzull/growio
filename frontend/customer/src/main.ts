import "~/main.css";
import { createApp } from "vue";
import { router } from "~/router";
import App from "~/App.vue";
import { register } from "swiper/element/bundle";
import { fetchPayload } from "~/composables/payload";

register();

const {
  params: { payload },
} = router.resolve(new URL(document.location.href).pathname);

fetchPayload(payload as string).then(() => {
  const app = createApp(App).use(router);
  router.isReady().then(() => app.mount("#app"));
});
