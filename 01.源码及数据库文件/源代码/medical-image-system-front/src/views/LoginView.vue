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
      <h2 class="title">医疗影像管理系统</h2>
      <p class="subtitle">登录您的账户</p>

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
  /* background: linear-gradient(135deg, #e0f2f7 0%, #c1e4f2 100%); */
  /* 渐变背景 */
  background: url("@/assets/background.jpg") no-repeat center center;
  background-size: cover;
}

.login-card {
  background: #ffffff;
  width: 400px;
  padding: 40px;
  border-radius: 12px;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.1);
  text-align: center;
  transition: all 0.3s ease; /* 添加过渡效果 */
}

.login-card:hover {
  transform: translateY(-5px); /* 鼠标悬停时轻微上浮 */
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15);
}

.title {
  font-size: 24px;
  margin-bottom: 10px;
  color: #2c3e50;
  font-weight: bold;
}

.subtitle {
  font-size: 16px;
  color: #7f8c8d;
  margin-bottom: 30px;
}

.login-tabs {
  margin-bottom: 25px;
}

.el-tab-pane {
  padding: 0 10px; /* 调整标签页内容内边距 */
}

.el-form-item {
  margin-bottom: 20px;
}

.login-btn,
.reset-btn {
  width: 100%;
  padding: 12px 0;
  font-size: 16px;
}

.login-btn {
  background-color: #007acc;
  border-color: #007acc;
  transition: background-color 0.3s, border-color 0.3s;
}

.login-btn:hover {
  background-color: #005f99;
  border-color: #005f99;
}

.register-link {
  margin-top: 15px;
  font-size: 14px;
  color: #007acc;
  text-decoration: none;
  transition: color 0.3s;
}

.register-link:hover {
  color: #005f99;
}

.divider {
  position: relative;
  height: 1px;
  background-color: #ecf0f1;
  margin: 30px 0;
}

.divider-text {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  background-color: #ffffff;
  padding: 0 15px;
  color: #bdc3c7;
  font-size: 13px;
}

.social-login {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-top: 20px;
}

.social-login .el-button {
  width: 45px;
  height: 45px;
  font-size: 20px;
  /* 移除了 color 和 border-color，让按钮更简洁 */
  transition: all 0.3s ease;
}

.social-login .el-button:hover {
  background-color: #f5f7fa; /* 设置一个通用的悬停背景色 */
  transform: translateY(-3px);
}
.social-icon {
  width: 25px;
  height: 25px;
}

.fade-in {
  animation: fadeIn 0.8s ease-in-out;
}

@keyframes fadeIn {
  0% {
    opacity: 0;
    transform: translateY(30px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
