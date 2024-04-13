<template>
  <div :class="$style.invitation" :loading="isLoading">
    <Modal v-if="invitation">
      <template #heading> Invitation </template>

      <span>
        You were invited to <b>{{ invitation.marketplace.name }}</b> for role
        <b>{{ invitation.role.name }}</b>
      </span>

      <template #footer>
        <Button :disabled="isLoading" size="md" @click="acceptInvitation"
          >Accept</Button
        >
      </template>
    </Modal>
    <LoaderIcon v-else />
  </div>
</template>

<script setup lang="ts">
import LoaderIcon from "~/components/LoaderIcon.vue";
import Modal from "~/components/Modal.vue";
import { account } from "~/composables/account";
import { apiAuthSignout } from "~/api/growio/auth";
import { useRoute, useRouter } from "vue-router";
import {
  apiMarketplaceAccountEmailInvitationsAcceptReceived,
  apiMarketplaceAccountEmailInvitationsGetReceived,
} from "~/api/growio/marketplace_account_email_invitations";
import { Wait, wait } from "~/composables/wait";
import { computed, ref } from "vue";
import { MarketplaceAccountEmailInvitation } from "~/api/growio/marketplace_account_email_invitations/types";
import Button from "~/components/Button.vue";

account.value && location.reload();
apiAuthSignout().catch(console.error);

const route = useRoute();
const router = useRouter();
const invitation = ref<MarketplaceAccountEmailInvitation>();

const isLoading = computed(() =>
  wait.some([
    Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_FETCH,
    Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_ACCEPT,
  ])
);

const fetchInvitation = async () => {
  try {
    const { email, password } = route.params;

    wait.start(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_FETCH);

    invitation.value = await apiMarketplaceAccountEmailInvitationsGetReceived({
      email: email as string,
      password: password as string,
    });
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_FETCH);
  }
};

const acceptInvitation = async () => {
  try {
    const { email, password } = route.params;
    wait.start(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_ACCEPT);
    await apiMarketplaceAccountEmailInvitationsAcceptReceived({
      email: email as string,
      password: password as string,
    });
    router.push("/");
  } catch (e) {
    console.error(e);
  } finally {
    wait.end(Wait.MARKETPLACE_ACCOUNT_EMAIL_INVITATION_ACCEPT);
  }
};

fetchInvitation();
</script>

<style module>
.invitation {
  height: 100%;
  display: flex;
  flex-flow: column;
  justify-content: center;
  align-items: center;
}
</style>
