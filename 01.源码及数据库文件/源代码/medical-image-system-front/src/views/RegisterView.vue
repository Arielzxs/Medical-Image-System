<script setup>
import { reactive, ref } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { register } from "@/apis/user";
import {
  User,
  Lock,
  CreditCard,
  Phone,
  Message,
  Calendar,
  HomeFilled,
  Male,
  Female,
  Briefcase,
  UserFilled,
} from "@element-plus/icons-vue"; // 导入Element Plus图标

const router = useRouter();
const ruleFormRef = ref();

// 根据 User 实体类更新表单数据
const dataForm = reactive({
  username: "",
  password: "",
  idCard: "",
  age: null,
  gender: 0, // 默认值为 '男' (0)
  phone: "",
  birthDate: "",
  address: "",
  role: "",
});

// 为所有字段添加校验规则
const rules = reactive({
  username: [
    { required: true, message: "用户名不能为空", trigger: "blur" },
    { min: 3, max: 10, message: "长度应在 3 到 10 个字符", trigger: "blur" },
  ],
  password: [
    { required: true, message: "密码不能为空", trigger: "blur" },
    { min: 8, max: 20, message: "长度应在 8 到 20 个字符", trigger: "blur" },
  ],
  idCard: [
    { required: true, message: "身份证号不能为空", trigger: "blur" },
    { len: 18, message: "身份证号长度必须为18位", trigger: "blur" },
  ],
  age: [{ required: true, message: "年龄不能为空", trigger: "blur" }],
  gender: [{ required: true, message: "请选择性别", trigger: "change" }],
  phone: [{ required: true, message: "电话号码不能为空", trigger: "blur" }],
  role: [{ required: true, message: "请选择身份", trigger: "change" }],
});

const submitForm = () => {
  if (!ruleFormRef.value) return;
  ruleFormRef.value.validate((valid) => {
    if (valid) {
      register(dataForm).then(() => {
        ElMessage.success("注册成功！即将跳转到登录页面。");
        setTimeout(() => {
          router.push("/login");
        }, 1500);
      });
    } else {
      ElMessage.error("请检查表单是否填写完整");
    }
  });
};

const handleReset = () => {
  if (!ruleFormRef.value) return;
  ruleFormRef.value.resetFields();
};

const goToLogin = () => {
  router.push("/login");
};
</script>

<template>
  <div class="register-page">
    <div class="register-card fade-in">
      <h2 class="title">医疗影像管理系统</h2>
      <p class="subtitle">创建您的新账户</p>
      <el-form
        ref="ruleFormRef"
        :model="dataForm"
        :rules="rules"
        label-width="0px"
        class="register-form"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item prop="username">
              <el-input
                v-model="dataForm.username"
                placeholder="用户名"
                :prefix-icon="User"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item prop="password">
              <el-input
                v-model="dataForm.password"
                type="password"
                placeholder="密码"
                show-password
                :prefix-icon="Lock"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item prop="idCard">
              <el-input
                v-model="dataForm.idCard"
                placeholder="身份证号"
                :prefix-icon="CreditCard"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item prop="phone">
              <el-input
                v-model="dataForm.phone"
                placeholder="电话号码"
                :prefix-icon="Phone"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item prop="age">
              <el-input-number
                v-model="dataForm.age"
                :min="1"
                :max="120"
                placeholder="年龄"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item prop="gender">
              <el-radio-group v-model="dataForm.gender" style="width: 100%">
                <el-radio-button :label="0">
                  <el-icon><Male /></el-icon> 男
                </el-radio-button>
                <el-radio-button :label="1">
                  <el-icon><Female /></el-icon> 女
                </el-radio-button>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item prop="birthDate">
          <el-date-picker
            v-model="dataForm.birthDate"
            type="date"
            placeholder="选择出生日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
            :prefix-icon="Calendar"
          />
        </el-form-item>
        <el-form-item prop="address">
          <el-input
            v-model="dataForm.address"
            type="textarea"
            placeholder="请输入联系地址"
            :prefix-icon="HomeFilled"
            :rows="2"
          />
        </el-form-item>
        <el-form-item prop="role">
          <el-select
            v-model="dataForm.role"
            placeholder="请选择您的身份"
            style="width: 100%"
            :prefix-icon="UserFilled"
          >
            <el-option label="普通医生" value="doctor"></el-option>
            <el-option label="专家" value="expert"></el-option>
            <el-option label="管理员" value="admin"></el-option>
            <el-option label="患者" value="patient"></el-option>
          </el-select>
        </el-form-item>

        <div class="form-actions">
          <el-button type="primary" @click="submitForm" class="register-btn"
            >立即注册</el-button
          >
          <el-button @click="handleReset" class="reset-btn">重置</el-button>
          <el-button @click="goToLogin" class="login-link" link
            >已有账户？去登录</el-button
          >
        </div>
      </el-form>
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

.register-page {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  width: 100%;
  /* background: linear-gradient(135deg, #e6f7ff 0%, #aed6f1 100%);  */
  /* 渐变背景 */
  background: url("@/assets/background.jpg") no-repeat center center;
  background-size: cover;
}

.register-card {
  background: #ffffff;
  width: 550px; /* 注册页面稍宽，容纳更多字段 */
  padding: 35px 50px;
  border-radius: 12px;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.1);
  text-align: center;
  transition: all 0.3s ease;
}

.register-card:hover {
  transform: translateY(-5px);
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

.register-form {
  text-align: left;
}

.el-form-item {
  margin-bottom: 20px;
}

.form-actions {
  margin-top: 25px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
}

.register-btn,
.reset-btn {
  width: 100%;
  padding: 12px 0;
  font-size: 16px;
}

.register-btn {
  background-color: #007acc;
  border-color: #007acc;
  transition: background-color 0.3s, border-color 0.3s;
}

.register-btn:hover {
  background-color: #005f99;
  border-color: #005f99;
}

.login-link {
  font-size: 14px;
  color: #007acc;
  text-decoration: none;
  transition: color 0.3s;
}

.login-link:hover {
  color: #005f99;
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

/* 确保图标能够正确显示 */
.el-input__prefix-inner {
  display: flex;
  align-items: center;
}
</style>
