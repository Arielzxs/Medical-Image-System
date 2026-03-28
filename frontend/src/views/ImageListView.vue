<template>
  <div class="image-list">
    <el-card shadow="never" class="search-card">
      <el-row :gutter="16" align="middle">
        <el-col :span="6">
          <el-input
            v-model="keyword"
            placeholder="搜索患者姓名、检查编号"
            :prefix-icon="Search"
            clearable
            @change="loadData"
          />
        </el-col>
        <el-col :span="4">
          <el-button type="primary" :icon="Search" @click="loadData">搜索</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card shadow="never" style="margin-top: 16px;">
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column label="预览" width="80">
          <template #default="{ row }">
            <el-image
              :src="`/api/images/${row.id}/file`"
              fit="cover"
              style="width: 56px; height: 56px; border-radius: 4px;"
              :preview-src-list="[`/api/images/${row.id}/file`]"
              preview-teleported
            >
              <template #error>
                <div class="img-placeholder">
                  <el-icon><Picture /></el-icon>
                </div>
              </template>
            </el-image>
          </template>
        </el-table-column>
        <el-table-column prop="original_name" label="文件名" show-overflow-tooltip />
        <el-table-column prop="patient_name" label="患者姓名" width="100" />
        <el-table-column prop="exam_no" label="检查编号" width="120" />
        <el-table-column prop="exam_type" label="检查类型" width="90">
          <template #default="{ row }">
            <el-tag :type="examTypeColor(row.exam_type)" size="small">{{ row.exam_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="image_type" label="格式" width="70">
          <template #default="{ row }">
            <el-tag type="info" size="small">{{ (row.image_type || '').toUpperCase() }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="文件大小" width="100">
          <template #default="{ row }">{{ formatSize(row.file_size) }}</template>
        </el-table-column>
        <el-table-column prop="uploader_name" label="上传人" width="100" />
        <el-table-column prop="upload_date" label="上传时间" width="160" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/examinations/${row.examination_id}`)">查看检查</el-button>
            <el-button text type="danger" size="small" @click="deleteImage(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[20, 50, 100]"
          layout="total, sizes, prev, pager, next"
          @current-change="loadData"
          @size-change="loadData"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import api from '@/api'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const keyword = ref('')

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
    const res = await api.get('/images', {
      params: { page: page.value, page_size: pageSize.value }
    })
    tableData.value = res.data.rows
    total.value = res.data.total
  } catch {} finally {
    loading.value = false
  }
}

async function deleteImage(row) {
  await ElMessageBox.confirm('确认删除该影像吗？此操作不可恢复。', '警告', { type: 'warning' })
  try {
    await api.delete(`/images/${row.id}`)
    ElMessage.success('删除成功')
    loadData()
  } catch {}
}

onMounted(loadData)
</script>

<style scoped>
.image-list { padding: 4px; }
.search-card { border: none; }
.pagination { margin-top: 16px; display: flex; justify-content: flex-end; }

.img-placeholder {
  width: 56px;
  height: 56px;
  background: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  color: #909399;
}
</style>
