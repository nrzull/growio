import "~/main.css";
import { createApp } from "vue";
import { router } from "~/router";
import App from "~/App.vue";
import { register } from "swiper/element/bundle";

register();

const app = createApp(App).use(router);

router.isReady().then(() => app.mount("#app"));
