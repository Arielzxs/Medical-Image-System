<script setup>
import { reactive, ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { adminUpdate, adminDetail } from "@/apis/user";
import { useRouter, useRoute } from "vue-router";
import { Refresh } from "@element-plus/icons-vue"; // 导入 Refresh 图标

const route = useRoute();
const router = useRouter();
const ruleFormRef = ref();

// 用于编辑的表单数据
const dataForm = reactive({
  id: 0,
  username: "",
  idCard: "",
  age: null,
  gender: 0,
  phone: "",
  birthDate: "",
  address: "",
  role: "",
});

// 用于存储原始用户信息的备份
const originalDataForm = ref({});

onMounted(async () => {
  const id = route.query.id;
  if (id) {
    try {
      const res = await adminDetail(id);
      const user = res.data;

      // 同时填充表单数据和备份数据
      Object.assign(dataForm, user);
      originalDataForm.value = { ...user };
    } catch (error) {
      ElMessage.error("获取用户信息失败");
    }
  }
});

const rules = reactive({
  username: [
    { required: true, message: "用户名不能为空", trigger: "blur" },
    { min: 3, max: 10, message: "用户名的长度是3-10个字符", trigger: "blur" },
  ],
  idCard: [
    { required: true, message: "身份证号不能为空", trigger: "blur" },
    { len: 18, message: "身份证不正确", trigger: "blur" },
  ],
  age: [{ required: true, message: "年龄不能为空", trigger: "blur" }],
  phone: [{ required: true, message: "电话不能为空", trigger: "blur" }],
  birthDate: [
    { required: true, message: "出生日期不能为空", trigger: "change" },
  ],
  address: [{ required: true, message: "地址不能为空", trigger: "blur" }],
  role: [{ required: true, message: "角色不能为空", trigger: "change" }],
});

const submitForm = () => {
  if (!ruleFormRef.value) return;
  ruleFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await adminUpdate(dataForm);
        ElMessage.success("更新用户成功");
        router.push({ path: "/admin/page" });
      } catch (error) {
        ElMessage.error("更新用户失败");
      }
    }
  });
};

// 重置功能
const handleReset = () => {
  // 将表单数据恢复为原始数据
  Object.assign(dataForm, originalDataForm.value);
  ElMessage.info("已重置为原始信息");
};

const handleReturnBack = () => {
  router.push({ path: "/admin/page" });
};
</script>

<template>
  <h1>编辑用户</h1>
  <el-card>
    <el-form
      ref="ruleFormRef"
      style="max-width: 600px"
      :model="dataForm"
      :rules="rules"
      label-width="auto"
    >
      <el-form-item label="用户名" prop="username">
        <el-input v-model="dataForm.username" />
      </el-form-item>
      <el-form-item label="身份证号" prop="idCard">
        <el-input v-model="dataForm.idCard" />
      </el-form-item>
      <el-form-item label="年龄" prop="age">
        <el-input-number v-model="dataForm.age" :min="1" :max="120" />
      </el-form-item>
      <el-form-item label="电话" prop="phone">
        <el-input v-model="dataForm.phone" />
      </el-form-item>
      <el-form-item label="地址" prop="address">
        <el-input v-model="dataForm.address" type="textarea" />
      </el-form-item>
      <el-form-item label="性别" prop="gender">
        <el-radio-group v-model="dataForm.gender">
          <el-radio :label="0">男</el-radio>
          <el-radio :label="1">女</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="出生日期" prop="birthDate">
        <el-date-picker
          v-model="dataForm.birthDate"
          type="date"
          placeholder="选择日期"
          value-format="YYYY-MM-DD"
        />
      </el-form-item>
      <el-form-item label="角色" prop="role">
        <el-select v-model="dataForm.role" placeholder="请选择角色">
          <el-option label="普通医生" value="doctor"></el-option>
          <el-option label="专家" value="expert"></el-option>
          <el-option label="管理员" value="admin"></el-option>
          <el-option label="患者" value="patient"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">保存</el-button>
        <el-button :icon="Refresh" @click="handleReset">重置</el-button>
        <el-button @click="handleReturnBack">返回</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>
