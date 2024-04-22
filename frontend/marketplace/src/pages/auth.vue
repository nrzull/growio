<template>
  <div :class="$style.auth">
    <Shape :class="$style.form">
      <Heading>Authentication</Heading>

      <template v-if="stage === 1">
        <TextInput v-model="state.email" placeholder="email" />
        <Button :disabled="isLoading" @click="submitSendEmail">
          Get verification code
        </Button>
      </template>

      <template v-if="stage === 2">
        <TextInput v-model="state.password" placeholder="verification code" />
        <Notification
          :model-value="{
            text: 'Check your email for verification code',
            type: 'info',
          }"
        />
        <Button :disabled="isLoading" @click="submitSendEmailOtp">
          Submit
        </Button>
      </template>
    </Shape>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import Shape from "@growio/shared/components/Shape.vue";
import Button from "@growio/shared/components/Button.vue";
import Heading from "@growio/shared/components/Shape/Heading.vue";
import TextInput from "@growio/shared/components/TextInput.vue";
import { useEmailAuth } from "~/composables/use-email-auth";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import { account } from "~/composables/account";
import { apiAuthSignout } from "@growio/shared/api/growio/auth";
import { useRoute, useRouter } from "vue-router";

account.value && location.reload();
apiAuthSignout().catch((e) => console.error(e));

const route = useRoute();
const router = useRouter();

const redirect = () =>
  route.query.to
    ? router.push(route.query.to as string)
    : router.push({ path: "/" });

const stage = ref<1 | 2>(1);

const { state, isLoading, sendEmail, sendEmailOtp } = useEmailAuth();

const submitSendEmail = () => sendEmail().then(() => (stage.value = 2));
const submitSendEmailOtp = () => sendEmailOtp().then(redirect);
</script>

<style module>
.auth {
  height: 100%;
  display: flex;
  flex-flow: column;
  justify-content: center;
  align-items: center;
}

.form {
  width: 420px;
  display: flex;
  flex-flow: column;
  gap: 24px;
}
</style>
