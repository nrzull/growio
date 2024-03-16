import { computed, reactive } from "vue";
import { wait } from "~/composables/wait";
import { apiAuthSendEmail, apiAuthSendEmailOtp } from "~/api/growio";

const WAIT_SEND_EMAIL = "WAIT_SEND_EMAIL";
const WAIT_SEND_EMAIL_OTP = "WAIT_SEND_EMAIL_OTP";

export const useEmailAuth = () => {
  const state = reactive({ email: "", password: "", expiredAt: "" });

  const isLoading = computed(() =>
    wait.some([WAIT_SEND_EMAIL, WAIT_SEND_EMAIL_OTP])
  );

  const sendEmail = async () => {
    try {
      wait.start(WAIT_SEND_EMAIL);

      const { expiredAt, password } = await apiAuthSendEmail({
        email: state.email,
      });

      state.expiredAt = expiredAt;
      state.password = password;
    } catch (e) {
      console.error(e);
    } finally {
      wait.end(WAIT_SEND_EMAIL);
    }
  };

  const sendEmailOtp = async () => {
    try {
      wait.start(WAIT_SEND_EMAIL_OTP);

      await apiAuthSendEmailOtp({
        email: state.email,
        password: state.password,
      });
    } catch (e) {
      console.error(e);
    } finally {
      wait.end(WAIT_SEND_EMAIL_OTP);
    }
  };

  return { state, isLoading, sendEmail, sendEmailOtp };
};
