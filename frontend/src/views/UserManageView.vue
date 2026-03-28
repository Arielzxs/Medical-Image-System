<template>
  <div class="user-manage">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-button type="primary" :icon="Plus" @click="openAdd">新增用户</el-button>
        </div>
      </template>

      <el-table :data="users" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="real_name" label="真实姓名" width="120" />
        <el-table-column prop="role" label="角色" width="90">
          <template #default="{ row }">
            <el-tag :type="row.role === 'admin' ? 'danger' : 'primary'" size="small">
              {{ row.role === 'admin' ? '管理员' : '医生' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="department" label="科室" />
        <el-table-column prop="created_at" label="创建时间" width="160" />
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button text type="danger" size="small" @click="deleteUser(row)" :disabled="row.id === currentUserId">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Add User Dialog -->
    <el-dialog v-model="dialogVisible" title="新增用户" width="460px" @closed="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
        </el-form-item>
        <el-form-item label="真实姓名">
          <el-input v-model="form.real_name" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-radio-group v-model="form.role">
            <el-radio value="admin">管理员</el-radio>
            <el-radio value="doctor">医生</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="科室">
          <el-input v-model="form.department" placeholder="请输入科室" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitForm">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { useAuthStore } from '@/store/auth'
import api from '@/api'

const authStore = useAuthStore()
const currentUserId = computed(() => authStore.user?.id)

const loading = ref(false)
const submitting = ref(false)
const users = ref([])
const dialogVisible = ref(false)
const formRef = ref(null)

const form = reactive({ username: '', password: '', real_name: '', role: 'doctor', department: '' })
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }, { min: 6, message: '密码至少6位', trigger: 'blur' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

async function loadUsers() {
  loading.value = true
  try {
    const res = await api.get('/auth/users')
    users.value = res.data
  } catch {} finally {
    loading.value = false
  }
}

function openAdd() {
  dialogVisible.value = true
}

function resetForm() {
  Object.assign(form, { username: '', password: '', real_name: '', role: 'doctor', department: '' })
  formRef.value?.resetFields()
}

async function submitForm() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    await api.post('/auth/users', form)
    ElMessage.success('创建成功')
    dialogVisible.value = false
    loadUsers()
  } catch {} finally {
    submitting.value = false
  }
}

async function deleteUser(row) {
  await ElMessageBox.confirm(`确认删除用户 "${row.username}" 吗？`, '警告', { type: 'warning' })
  try {
    await api.delete(`/auth/users/${row.id}`)
    ElMessage.success('删除成功')
    loadUsers()
  } catch {}
}

onMounted(loadUsers)
</script>

<style scoped>
.user-manage { padding: 4px; }
.card-header { display: flex; justify-content: space-between; align-items: center; font-weight: 600; }
</style>
