<template>
  <div class="examination-list">
    <el-card shadow="never" class="search-card">
      <el-row :gutter="16" align="middle">
        <el-col :span="6">
          <el-input
            v-model="keyword"
            placeholder="搜索检查编号、患者姓名"
            :prefix-icon="Search"
            clearable
            @change="loadData"
          />
        </el-col>
        <el-col :span="4">
          <el-select v-model="filterStatus" placeholder="状态筛选" clearable @change="loadData">
            <el-option label="待处理" value="pending" />
            <el-option label="已完成" value="completed" />
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-select v-model="filterType" placeholder="检查类型" clearable @change="loadData">
            <el-option label="CT" value="CT" />
            <el-option label="MRI" value="MRI" />
            <el-option label="X-Ray" value="X-Ray" />
            <el-option label="B超" value="B超" />
            <el-option label="PET" value="PET" />
          </el-select>
        </el-col>
        <el-col :span="2">
          <el-button type="primary" :icon="Search" @click="loadData">搜索</el-button>
        </el-col>
        <el-col :span="8" style="text-align: right;">
          <el-button type="primary" :icon="Plus" @click="openAdd">新增检查</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card shadow="never" style="margin-top: 16px;">
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="exam_no" label="检查编号" width="120" />
        <el-table-column prop="patient_name" label="患者姓名" width="100" />
        <el-table-column prop="patient_no" label="病历号" width="110" />
        <el-table-column prop="exam_type" label="检查类型" width="90">
          <template #default="{ row }">
            <el-tag :type="examTypeColor(row.exam_type)" size="small">{{ row.exam_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="body_part" label="检查部位" width="100" />
        <el-table-column prop="exam_date" label="检查日期" width="110" />
        <el-table-column prop="doctor_name" label="检查医生" width="100" />
        <el-table-column prop="image_count" label="影像数" width="80">
          <template #default="{ row }">
            <el-tag type="info" size="small">{{ row.image_count }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 'completed' ? 'success' : 'warning'" size="small">
              {{ row.status === 'completed' ? '已完成' : '待处理' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/examinations/${row.id}`)">详情</el-button>
            <el-button text type="warning" size="small" @click="openEdit(row)">编辑</el-button>
            <el-button text type="danger" size="small" @click="deleteExam(row)">删除</el-button>
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
      :title="editingId ? '编辑检查' : '新增检查'"
      width="560px"
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="患者" prop="patient_id">
          <el-select
            v-model="form.patient_id"
            placeholder="选择患者"
            filterable
            remote
            :remote-method="searchPatients"
            style="width:100%"
          >
            <el-option
              v-for="p in patientOptions"
              :key="p.id"
              :label="`${p.name} (${p.patient_no})`"
              :value="p.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="检查类型" prop="exam_type">
          <el-select v-model="form.exam_type" placeholder="选择检查类型" style="width:100%">
            <el-option label="CT" value="CT" />
            <el-option label="MRI" value="MRI" />
            <el-option label="X-Ray" value="X-Ray" />
            <el-option label="B超" value="B超" />
            <el-option label="PET" value="PET" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="检查日期" prop="exam_date">
          <el-date-picker v-model="form.exam_date" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="检查部位">
          <el-input v-model="form.body_part" placeholder="如：胸部、腹部、头颅" />
        </el-form-item>
        <el-form-item label="检查设备">
          <el-input v-model="form.equipment" placeholder="如：西门子CT" />
        </el-form-item>
        <el-form-item v-if="editingId" label="状态">
          <el-select v-model="form.status" style="width:100%">
            <el-option label="待处理" value="pending" />
            <el-option label="已完成" value="completed" />
          </el-select>
        </el-form-item>
        <el-form-item label="检查说明">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="检查说明" />
        </el-form-item>
        <el-form-item v-if="editingId" label="诊断结论">
          <el-input v-model="form.diagnosis" type="textarea" :rows="3" placeholder="诊断结论" />
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
const filterStatus = ref('')
const filterType = ref('')
const dialogVisible = ref(false)
const editingId = ref(null)
const formRef = ref(null)
const patientOptions = ref([])

const form = reactive({
  patient_id: null, exam_type: '', exam_date: '', body_part: '',
  equipment: '', status: 'pending', description: '', diagnosis: ''
})

const rules = {
  patient_id: [{ required: true, message: '请选择患者', trigger: 'change' }],
  exam_type: [{ required: true, message: '请选择检查类型', trigger: 'change' }],
  exam_date: [{ required: true, message: '请选择检查日期', trigger: 'change' }]
}

function examTypeColor(type) {
  const map = { 'CT': 'primary', 'MRI': 'success', 'X-Ray': 'warning', 'B超': 'info', 'PET': 'danger' }
  return map[type] || 'info'
}

async function loadData() {
  loading.value = true
  try {
    const res = await api.get('/examinations', {
      params: { page: page.value, page_size: pageSize.value, keyword: keyword.value, status: filterStatus.value, exam_type: filterType.value }
    })
    tableData.value = res.data.rows
    total.value = res.data.total
  } catch {} finally {
    loading.value = false
  }
}

async function searchPatients(query) {
  if (!query) return
  try {
    const res = await api.get('/patients', { params: { keyword: query, page_size: 20 } })
    patientOptions.value = res.data.rows
  } catch {}
}

async function loadPatients() {
  try {
    const res = await api.get('/patients', { params: { page_size: 50 } })
    patientOptions.value = res.data.rows
  } catch {}
}

function openAdd() {
  editingId.value = null
  loadPatients()
  dialogVisible.value = true
}

function openEdit(row) {
  editingId.value = row.id
  loadPatients()
  Object.assign(form, {
    patient_id: row.patient_id,
    exam_type: row.exam_type,
    exam_date: row.exam_date,
    body_part: row.body_part || '',
    equipment: row.equipment || '',
    status: row.status,
    description: row.description || '',
    diagnosis: row.diagnosis || ''
  })
  dialogVisible.value = true
}

function resetForm() {
  editingId.value = null
  Object.assign(form, { patient_id: null, exam_type: '', exam_date: '', body_part: '', equipment: '', status: 'pending', description: '', diagnosis: '' })
  formRef.value?.resetFields()
}

async function submitForm() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    if (editingId.value) {
      await api.put(`/examinations/${editingId.value}`, form)
      ElMessage.success('更新成功')
    } else {
      await api.post('/examinations', form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadData()
  } catch {} finally {
    submitting.value = false
  }
}

async function deleteExam(row) {
  await ElMessageBox.confirm(`确认删除检查 "${row.exam_no}" 吗？`, '警告', { type: 'warning' })
  try {
    await api.delete(`/examinations/${row.id}`)
    ElMessage.success('删除成功')
    loadData()
  } catch {}
}

onMounted(loadData)
</script>

<style scoped>
.examination-list { padding: 4px; }
.search-card { border: none; }
.pagination { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
