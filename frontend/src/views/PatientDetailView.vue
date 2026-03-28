<template>
  <div class="patient-detail" v-loading="loading">
    <el-page-header @back="$router.push('/patients')" class="page-header">
      <template #content>
        <span>患者详情 - {{ patient?.name }}</span>
      </template>
      <template #extra>
        <el-button type="primary" :icon="Plus" @click="openAddExam">新增检查</el-button>
      </template>
    </el-page-header>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- Patient Info Card -->
      <el-col :span="8">
        <el-card shadow="never" class="info-card">
          <template #header>
            <div class="card-header">
              <el-icon><User /></el-icon>
              <span>基本信息</span>
            </div>
          </template>
          <el-descriptions :column="1" border size="small" v-if="patient">
            <el-descriptions-item label="病历号">{{ patient.patient_no }}</el-descriptions-item>
            <el-descriptions-item label="姓名">{{ patient.name }}</el-descriptions-item>
            <el-descriptions-item label="性别">
              <el-tag :type="patient.gender === '男' ? 'primary' : 'danger'" size="small">{{ patient.gender }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="出生日期">{{ patient.birth_date }}</el-descriptions-item>
            <el-descriptions-item label="联系电话">{{ patient.phone }}</el-descriptions-item>
            <el-descriptions-item label="身份证号">{{ patient.id_card }}</el-descriptions-item>
            <el-descriptions-item label="家庭住址">{{ patient.address }}</el-descriptions-item>
            <el-descriptions-item label="既往病史">{{ patient.medical_history }}</el-descriptions-item>
            <el-descriptions-item label="建档时间">{{ patient.created_at }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>

      <!-- Examinations -->
      <el-col :span="16">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <el-icon><Document /></el-icon>
              <span>检查记录</span>
              <el-tag type="info" size="small" style="margin-left:8px;">共 {{ exams.length }} 条</el-tag>
            </div>
          </template>

          <el-timeline v-if="exams.length > 0">
            <el-timeline-item
              v-for="exam in exams"
              :key="exam.id"
              :timestamp="exam.exam_date"
              :type="exam.status === 'completed' ? 'success' : 'warning'"
              placement="top"
            >
              <el-card class="exam-card" shadow="hover" @click="$router.push(`/examinations/${exam.id}`)">
                <div class="exam-header">
                  <div>
                    <el-tag :type="examTypeColor(exam.exam_type)" size="small">{{ exam.exam_type }}</el-tag>
                    <span class="exam-no">{{ exam.exam_no }}</span>
                  </div>
                  <el-tag :type="exam.status === 'completed' ? 'success' : 'warning'" size="small">
                    {{ exam.status === 'completed' ? '已完成' : '待处理' }}
                  </el-tag>
                </div>
                <div class="exam-detail">
                  <span v-if="exam.body_part"><el-icon><Location /></el-icon> {{ exam.body_part }}</span>
                  <span v-if="exam.equipment"><el-icon><Monitor /></el-icon> {{ exam.equipment }}</span>
                  <span v-if="exam.doctor_name"><el-icon><User /></el-icon> {{ exam.doctor_name }}</span>
                  <span><el-icon><Picture /></el-icon> {{ exam.image_count }} 张影像</span>
                </div>
                <div class="exam-diagnosis" v-if="exam.diagnosis">
                  <strong>诊断：</strong>{{ exam.diagnosis }}
                </div>
              </el-card>
            </el-timeline-item>
          </el-timeline>

          <el-empty v-else description="暂无检查记录" />
        </el-card>
      </el-col>
    </el-row>

    <!-- Add Examination Dialog -->
    <el-dialog v-model="examDialogVisible" title="新增检查" width="520px" @closed="resetExamForm">
      <el-form ref="examFormRef" :model="examForm" :rules="examRules" label-width="90px">
        <el-form-item label="检查类型" prop="exam_type">
          <el-select v-model="examForm.exam_type" placeholder="选择检查类型" style="width:100%">
            <el-option label="CT" value="CT" />
            <el-option label="MRI" value="MRI" />
            <el-option label="X-Ray" value="X-Ray" />
            <el-option label="B超" value="B超" />
            <el-option label="PET" value="PET" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="检查日期" prop="exam_date">
          <el-date-picker v-model="examForm.exam_date" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="检查部位">
          <el-input v-model="examForm.body_part" placeholder="如：胸部、腹部、头颅" />
        </el-form-item>
        <el-form-item label="检查设备">
          <el-input v-model="examForm.equipment" placeholder="如：西门子CT" />
        </el-form-item>
        <el-form-item label="检查说明">
          <el-input v-model="examForm.description" type="textarea" :rows="3" placeholder="检查说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="examDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="examSubmitting" @click="submitExam">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import api from '@/api'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const patient = ref(null)
const exams = ref([])
const examDialogVisible = ref(false)
const examSubmitting = ref(false)
const examFormRef = ref(null)

const examForm = reactive({
  exam_type: '', exam_date: '', body_part: '', equipment: '', description: ''
})

const examRules = {
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
    const [pRes, eRes] = await Promise.all([
      api.get(`/patients/${route.params.id}`),
      api.get(`/patients/${route.params.id}/examinations`)
    ])
    patient.value = pRes.data
    exams.value = eRes.data
  } catch {} finally {
    loading.value = false
  }
}

function openAddExam() {
  examDialogVisible.value = true
}

function resetExamForm() {
  Object.assign(examForm, { exam_type: '', exam_date: '', body_part: '', equipment: '', description: '' })
  examFormRef.value?.resetFields()
}

async function submitExam() {
  const valid = await examFormRef.value?.validate().catch(() => false)
  if (!valid) return

  examSubmitting.value = true
  try {
    await api.post('/examinations', { ...examForm, patient_id: parseInt(route.params.id) })
    ElMessage.success('检查记录创建成功')
    examDialogVisible.value = false
    loadData()
  } catch {} finally {
    examSubmitting.value = false
  }
}

onMounted(loadData)
</script>

<style scoped>
.patient-detail { padding: 4px; }
.page-header { margin-bottom: 8px; }
.info-card { border: none; }

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.exam-card {
  cursor: pointer;
  transition: box-shadow 0.2s;
}

.exam-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
}

.exam-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.exam-no {
  font-size: 13px;
  color: #606266;
  margin-left: 8px;
}

.exam-detail {
  display: flex;
  gap: 16px;
  font-size: 13px;
  color: #909399;
  align-items: center;
}

.exam-detail .el-icon {
  margin-right: 2px;
}

.exam-diagnosis {
  margin-top: 8px;
  font-size: 13px;
  color: #606266;
  background: #f5f7fa;
  padding: 6px 10px;
  border-radius: 4px;
}
</style>
