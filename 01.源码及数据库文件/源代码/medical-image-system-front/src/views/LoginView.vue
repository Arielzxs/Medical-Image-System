<script setup>
import { ref, reactive, onMounted } from "vue";
import { login, loginByPhone } from "@/apis/user";
import { useAdminStore } from "@/stores/admin";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { User, Lock, Phone } from "@element-plus/icons-vue";

const router = useRouter();
const adminStore = useAdminStore();
const activeTab = ref("idCard"); // 'idCard' 或 'phone'
const captchaUrl = ref("/api/captcha/generate");

const refreshCaptcha = () => {
  captchaUrl.value = "/api/captcha/generate?t=" + new Date().getTime();
};

onMounted(() => {
  refreshCaptcha();
});

// 身份证登录表单
const idCardForm = reactive({
  idCard: "",
  password: "",
  captcha: "",
});
const idCardFormRef = ref();
const idCardRules = reactive({
  idCard: [{ required: true, message: "身份证号不能为空", trigger: "blur" }],
  password: [{ required: true, message: "密码不能为空", trigger: "blur" }],
  captcha: [{ required: true, message: "验证码不能为空", trigger: "blur" }],
});

// 手机号登录表单
const phoneForm = reactive({
  phone: "",
  password: "",
  captcha: "",
});
const phoneFormRef = ref();
const phoneRules = reactive({
  phone: [{ required: true, message: "手机号不能为空", trigger: "blur" }],
  password: [{ required: true, message: "密码不能为空", trigger: "blur" }],
  captcha: [{ required: true, message: "验证码不能为空", trigger: "blur" }],
});

const submitForm = () => {
  let formRef;
  let loginAction;
  let formData;

  if (activeTab.value === "idCard") {
    formRef = idCardFormRef.value;
    loginAction = login;
    formData = idCardForm;
  } else {
    formRef = phoneFormRef.value;
    loginAction = loginByPhone;
    formData = phoneForm;
  }

  if (!formRef) return;
  formRef.validate((valid) => {
    if (valid) {
      loginAction(formData)
        .then((res) => {
          adminStore.saveToken(res.message);
          adminStore.saveAdmin(res.data);
          ElMessage.success("登录成功");
          window.location.href = "/home";
        })
        .catch(() => {
          // 登录失败时刷新验证码
          refreshCaptcha();
        });
    }
  });
};

const handleReset = () => {
  if (activeTab.value === "idCard") {
    idCardFormRef.value.resetFields();
  } else {
    phoneFormRef.value.resetFields();
  }
};

const goToRegister = () => {
  router.push("/register");
};
</script>

<template>
  <div class="login-page">
    <div class="login-card fade-in">
      <div class="logo-area">
        <span class="logo-icon">🏥</span>
      </div>
      <h2 class="title">医疗影像管理系统</h2>
      <p class="subtitle">请登录您的账户以继续</p>

      <el-tabs v-model="activeTab" class="login-tabs" stretch>
        <el-tab-pane label="身份证登录" name="idCard">
          <el-form
            ref="idCardFormRef"
            :model="idCardForm"
            :rules="idCardRules"
            label-width="0px"
            class="login-form"
            @keyup.enter="submitForm"
          >
            <el-form-item prop="idCard">
              <el-input
                v-model="idCardForm.idCard"
                placeholder="请输入身份证号"
                :prefix-icon="User"
              />
            </el-form-item>
            <el-form-item prop="password">
              <el-input
                v-model="idCardForm.password"
                type="password"
                placeholder="请输入密码"
                show-password
                :prefix-icon="Lock"
              />
            </el-form-item>
            <el-form-item prop="captcha">
              <el-input v-model="idCardForm.captcha" placeholder="请输入验证码">
                <template #append>
                  <img
                    :src="captchaUrl"
                    @click="refreshCaptcha"
                    style="cursor: pointer"
                  />
                </template>
              </el-input>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="手机号登录" name="phone">
          <el-form
            ref="phoneFormRef"
            :model="phoneForm"
            :rules="phoneRules"
            label-width="0px"
            class="login-form"
            @keyup.enter="submitForm"
          >
            <el-form-item prop="phone">
              <el-input
                v-model="phoneForm.phone"
                placeholder="请输入手机号"
                :prefix-icon="Phone"
              />
            </el-form-item>
            <el-form-item prop="password">
              <el-input
                v-model="phoneForm.password"
                type="password"
                placeholder="请输入密码"
                show-password
                :prefix-icon="Lock"
              />
            </el-form-item>
            <el-form-item prop="captcha">
              <el-input v-model="phoneForm.captcha" placeholder="请输入验证码">
                <template #append>
                  <img
                    :src="captchaUrl"
                    @click="refreshCaptcha"
                    style="cursor: pointer"
                  />
                </template>
              </el-input>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>

      <div class="form-actions">
        <el-button type="primary" @click="submitForm" class="login-btn"
          >登录</el-button
        >
        <el-button @click="goToRegister" class="register-link" link
          >注册新账户</el-button
        >
      </div>

      <!-- <div class="divider">
        <span class="divider-text">其他登录方式</span>
      </div>
      <div class="social-login">
        <el-button circle><i class="fab fa-weixin"></i></el-button>
        <el-button circle><i class="fab fa-qq"></i></el-button>
        <el-button circle><i class="fab fa-alipay"></i></el-button>
      </div> -->
      <div class="divider">
        <span class="divider-text">其他登录方式</span>
      </div>
      <div class="social-login">
        <el-button circle>
          <img src="../assets/weichat.png" class="social-icon" alt="WeChat" />
        </el-button>
        <el-button circle>
          <img src="../assets/qq.png" class="social-icon" alt="QQ" />
        </el-button>
        <el-button circle>
          <img src="../assets/phone.png" class="social-icon" alt="Alipay" />
        </el-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
html,
body,
#app {
  height: 100%;
  margin: 0;
  padding: 0;
}

.login-page {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  width: 100%;
  background: url("@/assets/background.jpg") no-repeat center center;
  background-size: cover;
}

.login-page::before {
  content: "";
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  backdrop-filter: blur(2px);
}

.login-card {
  position: relative;
  z-index: 1;
  background: rgba(255, 255, 255, 0.96);
  width: 420px;
  padding: 44px 40px 36px;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.25);
  text-align: center;
  transition: all 0.3s ease;
}

.login-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 28px 70px rgba(0, 0, 0, 0.3);
}

.logo-area {
  margin-bottom: 20px;
}

.logo-icon {
  font-size: 42px;
  display: block;
  margin-bottom: 8px;
}

.title {
  font-size: 22px;
  margin-bottom: 6px;
  color: #1a2b45;
  font-weight: 700;
}

.subtitle {
  font-size: 14px;
  color: #9baab8;
  margin-bottom: 28px;
}

.login-tabs {
  margin-bottom: 20px;
}

.el-tab-pane {
  padding: 0 4px;
}

.el-form-item {
  margin-bottom: 18px;
}

.form-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 4px;
}

.login-btn {
  width: 100%;
  height: 44px;
  font-size: 15px;
  font-weight: 600;
  background: linear-gradient(135deg, #1a2b45, #1890ff) !important;
  border: none !important;
  border-radius: 10px !important;
  letter-spacing: 0.5px;
  transition: all 0.3s ease !important;
}

.login-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 18px rgba(24, 144, 255, 0.4) !important;
}

.register-link {
  font-size: 14px;
  color: #1890ff !important;
  transition: color 0.2s;
}

.register-link:hover {
  color: #40a9ff !important;
}

.divider {
  position: relative;
  height: 1px;
  background-color: #edf0f5;
  margin: 24px 0 20px;
}

.divider-text {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  background-color: rgba(255, 255, 255, 0.96);
  padding: 0 14px;
  color: #b0bec5;
  font-size: 12px;
}

.social-login {
  display: flex;
  justify-content: center;
  gap: 16px;
}

.social-login .el-button {
  width: 44px;
  height: 44px;
  border-radius: 50% !important;
  border-color: #e8ecf0 !important;
  transition: all 0.25s ease !important;
}

.social-login .el-button:hover {
  background-color: #f0f7ff !important;
  border-color: #1890ff !important;
  transform: translateY(-3px);
  box-shadow: 0 4px 12px rgba(24, 144, 255, 0.2);
}

.social-icon {
  width: 22px;
  height: 22px;
}

.fade-in {
  animation: fadeIn 0.7s ease-in-out;
}

@keyframes fadeIn {
  0% {
    opacity: 0;
    transform: translateY(24px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
