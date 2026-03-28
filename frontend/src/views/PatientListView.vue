<template>
  <div class="patient-list">
    <el-card shadow="never" class="search-card">
      <el-row :gutter="16" align="middle">
        <el-col :span="8">
          <el-input
            v-model="keyword"
            placeholder="搜索患者姓名、病历号、手机号"
            :prefix-icon="Search"
            clearable
            @change="loadData"
          />
        </el-col>
        <el-col :span="4">
          <el-button type="primary" :icon="Search" @click="loadData">搜索</el-button>
        </el-col>
        <el-col :span="12" style="text-align: right;">
          <el-button type="primary" :icon="Plus" @click="openAdd">新增患者</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card shadow="never" style="margin-top: 16px;">
      <el-table
        :data="tableData"
        stripe
        v-loading="loading"
        @row-click="row => $router.push(`/patients/${row.id}`)"
        style="cursor: pointer;"
      >
        <el-table-column prop="patient_no" label="病历号" width="120" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="gender" label="性别" width="70">
          <template #default="{ row }">
            <el-tag :type="row.gender === '男' ? 'primary' : 'danger'" size="small">{{ row.gender }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="birth_date" label="出生日期" width="110" />
        <el-table-column prop="phone" label="联系电话" width="130" />
        <el-table-column prop="address" label="地址" />
        <el-table-column prop="medical_history" label="病史" width="150" show-overflow-tooltip />
        <el-table-column prop="created_at" label="建档时间" width="160" />
        <el-table-column label="操作" width="160" fixed="right" @click.stop="">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click.stop="$router.push(`/patients/${row.id}`)">详情</el-button>
            <el-button text type="warning" size="small" @click.stop="openEdit(row)">编辑</el-button>
            <el-button text type="danger" size="small" @click.stop="deletePatient(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @current-change="loadData"
          @size-change="loadData"
        />
      </div>
    </el-card>

    <!-- Add/Edit Dialog -->
    <el-dialog
      v-model="dialogVisible"
      :title="editingId ? '编辑患者' : '新增患者'"
      width="560px"
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="患者姓名" prop="name">
              <el-input v-model="form.name" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-radio-group v-model="form.gender">
                <el-radio value="男">男</el-radio>
                <el-radio value="女">女</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="出生日期" prop="birth_date">
              <el-date-picker
                v-model="form.birth_date"
                type="date"
                placeholder="选择日期"
                value-format="YYYY-MM-DD"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="form.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="身份证号" prop="id_card">
              <el-input v-model="form.id_card" placeholder="请输入身份证号" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="家庭住址">
              <el-input v-model="form.address" placeholder="请输入家庭住址" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="既往病史">
              <el-input v-model="form.medical_history" type="textarea" :rows="3" placeholder="请输入既往病史" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitForm">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import api from '@/api'

const loading = ref(false)
const submitting = ref(false)
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const keyword = ref('')
const dialogVisible = ref(false)
const editingId = ref(null)
const formRef = ref(null)

const form = reactive({
  name: '', gender: '男', birth_date: '', phone: '', id_card: '', address: '', medical_history: ''
})

const rules = {
  name: [{ required: true, message: '请输入患者姓名', trigger: 'blur' }],
  gender: [{ required: true, message: '请选择性别', trigger: 'change' }]
}

async function loadData() {
  loading.value = true
  try {
    const res = await api.get('/patients', {
      params: { page: page.value, page_size: pageSize.value, keyword: keyword.value }
    })
    tableData.value = res.data.rows
    total.value = res.data.total
  } catch {} finally {
    loading.value = false
  }
}

function openAdd() {
  editingId.value = null
  dialogVisible.value = true
}

function openEdit(row) {
  editingId.value = row.id
  Object.assign(form, {
    name: row.name,
    gender: row.gender,
    birth_date: row.birth_date,
    phone: row.phone,
    id_card: row.id_card,
    address: row.address,
    medical_history: row.medical_history
  })
  dialogVisible.value = true
}

function resetForm() {
  editingId.value = null
  Object.assign(form, { name: '', gender: '男', birth_date: '', phone: '', id_card: '', address: '', medical_history: '' })
  formRef.value?.resetFields()
}

async function submitForm() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    if (editingId.value) {
      await api.put(`/patients/${editingId.value}`, form)
      ElMessage.success('更新成功')
    } else {
      await api.post('/patients', form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadData()
  } catch {} finally {
    submitting.value = false
  }
}

async function deletePatient(row) {
  await ElMessageBox.confirm(`确认删除患者 "${row.name}" 吗？此操作不可恢复。`, '警告', { type: 'warning' })
  try {
    await api.delete(`/patients/${row.id}`)
    ElMessage.success('删除成功')
    loadData()
  } catch {}
}

onMounted(loadData)
</script>

<style scoped>
.patient-list {
  padding: 4px;
}

.search-card {
  border: none;
}

.pagination {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
