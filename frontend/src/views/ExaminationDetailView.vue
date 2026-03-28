<template>
  <div class="examination-detail" v-loading="loading">
    <el-page-header @back="$router.push('/examinations')" class="page-header">
      <template #content>
        <span>检查详情 - {{ exam?.exam_no }}</span>
      </template>
      <template #extra>
        <el-button type="primary" :icon="Upload" @click="uploadDialogVisible = true">上传影像</el-button>
      </template>
    </el-page-header>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- Exam Info -->
      <el-col :span="10">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <el-icon><Document /></el-icon>
              <span>检查信息</span>
              <el-tag :type="exam?.status === 'completed' ? 'success' : 'warning'" size="small" style="margin-left:auto">
                {{ exam?.status === 'completed' ? '已完成' : '待处理' }}
              </el-tag>
            </div>
          </template>
          <el-descriptions :column="1" border size="small" v-if="exam">
            <el-descriptions-item label="检查编号">{{ exam.exam_no }}</el-descriptions-item>
            <el-descriptions-item label="患者姓名">
              <el-button text type="primary" @click="$router.push(`/patients/${exam.patient_id}`)">
                {{ exam.patient_name }} ({{ exam.patient_no }})
              </el-button>
            </el-descriptions-item>
            <el-descriptions-item label="检查类型">
              <el-tag :type="examTypeColor(exam.exam_type)" size="small">{{ exam.exam_type }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="检查日期">{{ exam.exam_date }}</el-descriptions-item>
            <el-descriptions-item label="检查部位">{{ exam.body_part }}</el-descriptions-item>
            <el-descriptions-item label="检查设备">{{ exam.equipment }}</el-descriptions-item>
            <el-descriptions-item label="检查医生">{{ exam.doctor_name }}</el-descriptions-item>
            <el-descriptions-item label="检查说明">{{ exam.description }}</el-descriptions-item>
          </el-descriptions>

          <!-- Diagnosis -->
          <div class="diagnosis-section">
            <div class="section-title">
              <el-icon><EditPen /></el-icon>
              <span>诊断结论</span>
            </div>
            <el-input
              v-model="diagnosis"
              type="textarea"
              :rows="4"
              placeholder="请输入诊断结论"
            />
            <el-button type="primary" size="small" style="margin-top: 8px;" @click="saveDiagnosis" :loading="savingDiagnosis">
              保存诊断
            </el-button>
          </div>
        </el-card>
      </el-col>

      <!-- Images -->
      <el-col :span="14">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <el-icon><Picture /></el-icon>
              <span>影像列表</span>
              <el-tag type="info" size="small" style="margin-left:8px">{{ images.length }} 张</el-tag>
            </div>
          </template>

          <div class="image-grid" v-if="images.length > 0">
            <div
              v-for="img in images"
              :key="img.id"
              class="image-item"
              @click="viewImage(img)"
            >
              <div class="image-preview">
                <el-image
                  :src="`/api/images/${img.id}/file`"
                  fit="cover"
                  :preview-src-list="images.map(i => `/api/images/${i.id}/file`)"
                  :initial-index="images.indexOf(img)"
                  preview-teleported
                  @click.stop
                >
                  <template #error>
                    <div class="image-error">
                      <el-icon :size="40"><Picture /></el-icon>
                      <span>{{ img.image_type?.toUpperCase() }}</span>
                    </div>
                  </template>
                </el-image>
              </div>
              <div class="image-info">
                <div class="image-name">{{ img.original_name }}</div>
                <div class="image-meta">
                  <span>{{ formatSize(img.file_size) }}</span>
                  <span>{{ img.upload_date?.split(' ')[0] }}</span>
                </div>
                <el-button
                  text type="danger" size="small"
                  @click.stop="deleteImage(img)"
                  class="image-delete"
                >
                  <el-icon><Delete /></el-icon>
                </el-button>
              </div>
            </div>
          </div>

          <el-empty v-else description="暂无影像，请上传影像文件" />
        </el-card>
      </el-col>
    </el-row>

    <!-- Upload Dialog -->
    <el-dialog v-model="uploadDialogVisible" title="上传影像" width="500px" @closed="uploadFiles = []">
      <el-upload
        ref="uploadRef"
        v-model:file-list="uploadFiles"
        action="#"
        :auto-upload="false"
        :accept="'.jpg,.jpeg,.png,.gif,.bmp,.dcm,.tiff,.tif,.webp'"
        multiple
        drag
        list-type="picture"
      >
        <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
        <div class="el-upload__text">拖拽文件到此处，或 <em>点击上传</em></div>
        <template #tip>
          <div class="el-upload__tip">支持 JPG/PNG/BMP/DICOM 等格式，单文件不超过 50MB</div>
        </template>
      </el-upload>
      <template #footer>
        <el-button @click="uploadDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="uploading" @click="submitUpload">上传</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Upload, UploadFilled } from '@element-plus/icons-vue'
import api from '@/api'

const route = useRoute()
const loading = ref(false)
const exam = ref(null)
const images = ref([])
const diagnosis = ref('')
const savingDiagnosis = ref(false)
const uploadDialogVisible = ref(false)
const uploading = ref(false)
const uploadFiles = ref([])

function examTypeColor(type) {
  const map = { 'CT': 'primary', 'MRI': 'success', 'X-Ray': 'warning', 'B超': 'info', 'PET': 'danger' }
  return map[type] || 'info'
}

function formatSize(bytes) {
  if (!bytes) return '-'
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / 1024 / 1024).toFixed(1) + ' MB'
}

async function loadData() {
  loading.value = true
  try {
    const res = await api.get(`/examinations/${route.params.id}`)
    exam.value = res.data
    images.value = res.data.images || []
    diagnosis.value = res.data.diagnosis || ''
  } catch {} finally {
    loading.value = false
  }
}

async function saveDiagnosis() {
  if (!exam.value) return
  savingDiagnosis.value = true
  try {
    await api.put(`/examinations/${route.params.id}`, {
      ...exam.value,
      diagnosis: diagnosis.value,
      doctor_id: exam.value.doctor_id
    })
    ElMessage.success('诊断保存成功')
    exam.value.diagnosis = diagnosis.value
    if (diagnosis.value) {
      exam.value.status = 'completed'
    }
  } catch {} finally {
    savingDiagnosis.value = false
  }
}

async function submitUpload() {
  if (!uploadFiles.value.length) {
    ElMessage.warning('请选择要上传的文件')
    return
  }

  uploading.value = true
  const formData = new FormData()
  formData.append('examination_id', route.params.id)
  for (const f of uploadFiles.value) {
    formData.append('files', f.raw)
  }

  try {
    const res = await api.post('/images/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    ElMessage.success(res.message)
    uploadDialogVisible.value = false
    uploadFiles.value = []
    loadData()
  } catch {} finally {
    uploading.value = false
  }
}

function viewImage(img) {
  // Image preview handled by el-image component
}

async function deleteImage(img) {
  await ElMessageBox.confirm('确认删除该影像吗？', '警告', { type: 'warning' })
  try {
    await api.delete(`/images/${img.id}`)
    ElMessage.success('删除成功')
    images.value = images.value.filter(i => i.id !== img.id)
  } catch {}
}

onMounted(loadData)
</script>

<style scoped>
.examination-detail { padding: 4px; }
.page-header { margin-bottom: 8px; }

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.diagnosis-section {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 10px;
}

.image-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 12px;
}

.image-item {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: box-shadow 0.2s;
  position: relative;
}

.image-item:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.12);
}

.image-preview {
  width: 100%;
  height: 140px;
  overflow: hidden;
}

.image-preview .el-image {
  width: 100%;
  height: 100%;
}

.image-error {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f5f7fa;
  color: #909399;
  font-size: 12px;
  gap: 8px;
}

.image-info {
  padding: 8px;
  position: relative;
}

.image-name {
  font-size: 12px;
  color: #303133;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.image-meta {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: #909399;
  margin-top: 4px;
}

.image-delete {
  position: absolute;
  top: 4px;
  right: 4px;
}
</style>
