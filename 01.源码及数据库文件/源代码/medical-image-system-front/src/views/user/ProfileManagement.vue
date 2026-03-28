<script setup>
import { reactive, onMounted, ref } from "vue";
import { ElMessage } from "element-plus";
import { getUserById, updateUser } from "@/apis/user";
import { useAdminStore } from "@/stores/admin";
import { Refresh } from "@element-plus/icons-vue"; // 导入 Refresh 图标

const store = useAdminStore();
const ruleFormRef = ref();

const dataForm = reactive({
  id: store.getAdmin.id,
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

const rules = reactive({
  username: [{ required: true, message: "用户名不能为空", trigger: "blur" }],
  idCard: [
    { required: true, message: "身份证号不能为空", trigger: "blur" },
    { len: 18, message: "身份证长度必须为18位", trigger: "blur" },
  ],
  phone: [{ required: true, message: "电话号码不能为空", trigger: "blur" }],
  address: [{ required: true, message: "地址不能为空", trigger: "blur" }],
  age: [{ required: true, message: "年龄不能为空", trigger: "blur" }],
});

onMounted(async () => {
  try {
    const res = await getUserById(dataForm.id);
    const user = res.data;

    // 同时填充表单数据和备份数据
    Object.assign(dataForm, user);
    originalDataForm.value = { ...user };
  } catch (error) {
    ElMessage.error("获取用户信息失败");
  }
});

const submitForm = () => {
  if (!ruleFormRef.value) return;
  ruleFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await updateUser(dataForm);
        ElMessage.success("用户信息更新成功");
        // 更新成功后，也更新备份数据
        originalDataForm.value = { ...dataForm };
      } catch (error) {
        ElMessage.error("用户信息更新失败");
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
</script>

<template>
  <h1>个人信息管理</h1>
  <el-card>
    <el-form
      ref="ruleFormRef"
      :model="dataForm"
      :rules="rules"
      label-width="120px"
      style="max-width: 600px"
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
      <el-form-item label="角色">
        <el-input v-model="dataForm.role" disabled />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">保存更新</el-button>
        <el-button :icon="Refresh" @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>
