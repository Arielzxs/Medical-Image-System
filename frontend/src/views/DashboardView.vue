<template>
  <div class="dashboard">
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <div class="stat-card blue">
          <div class="stat-icon"><el-icon :size="40"><User /></el-icon></div>
          <div class="stat-info">
            <div class="stat-num">{{ stats.patient_count }}</div>
            <div class="stat-label">患者总数</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card green">
          <div class="stat-icon"><el-icon :size="40"><Document /></el-icon></div>
          <div class="stat-info">
            <div class="stat-num">{{ stats.exam_count }}</div>
            <div class="stat-label">检查总数</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card purple">
          <div class="stat-icon"><el-icon :size="40"><Picture /></el-icon></div>
          <div class="stat-info">
            <div class="stat-num">{{ stats.image_count }}</div>
            <div class="stat-label">影像总数</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card orange">
          <div class="stat-icon"><el-icon :size="40"><Clock /></el-icon></div>
          <div class="stat-info">
            <div class="stat-num">{{ stats.pending_count }}</div>
            <div class="stat-label">待处理检查</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="content-row">
      <el-col :span="14">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>最近检查记录</span>
              <el-button text type="primary" @click="$router.push('/examinations')">查看全部</el-button>
            </div>
          </template>
          <el-table :data="stats.recent_exams" stripe size="small">
            <el-table-column prop="exam_no" label="检查编号" width="110" />
            <el-table-column prop="patient_name" label="患者姓名" width="90" />
            <el-table-column prop="exam_type" label="检查类型" width="80">
              <template #default="{ row }">
                <el-tag :type="examTypeColor(row.exam_type)" size="small">{{ row.exam_type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="exam_date" label="检查日期" width="100" />
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="row.status === 'completed' ? 'success' : 'warning'" size="small">
                  {{ row.status === 'completed' ? '已完成' : '待处理' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="70">
              <template #default="{ row }">
                <el-button text type="primary" size="small" @click="$router.push(`/examinations/${row.id}`)">详情</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <el-col :span="10">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>检查类型统计</span>
            </div>
          </template>
          <div class="type-stats">
            <div
              v-for="item in stats.exam_type_stats"
              :key="item.exam_type"
              class="type-item"
            >
              <div class="type-label">
                <el-tag :type="examTypeColor(item.exam_type)" size="small">{{ item.exam_type }}</el-tag>
                <span class="type-count">{{ item.count }} 例</span>
              </div>
              <el-progress
                :percentage="examPercent(item.count)"
                :color="examTypeColorHex(item.exam_type)"
                :stroke-width="12"
              />
            </div>
            <el-empty v-if="!stats.exam_type_stats?.length" description="暂无数据" :image-size="60" />
          </div>
        </el-card>

        <el-card shadow="never" style="margin-top: 20px;">
          <template #header>
            <div class="card-header"><span>完成率</span></div>
          </template>
          <div class="completion-chart">
            <el-progress
              type="dashboard"
              :percentage="completionRate"
              :color="completionColor"
            >
              <template #default="{ percentage }">
                <div class="progress-label">
                  <div class="progress-num">{{ percentage }}%</div>
                  <div class="progress-desc">完成率</div>
                </div>
              </template>
            </el-progress>
            <div class="completion-info">
              <div><span class="dot green"></span>已完成: {{ stats.completed_count }}</div>
              <div><span class="dot orange"></span>待处理: {{ stats.pending_count }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/api'

const stats = ref({
  patient_count: 0,
  exam_count: 0,
  image_count: 0,
  pending_count: 0,
  completed_count: 0,
  recent_exams: [],
  exam_type_stats: []
})

const completionRate = computed(() => {
  const total = stats.value.exam_count
  if (!total) return 0
  return Math.round((stats.value.completed_count / total) * 100)
})

const completionColor = computed(() => {
  const r = completionRate.value
  if (r >= 80) return '#67c23a'
  if (r >= 50) return '#e6a23c'
  return '#f56c6c'
})

function examTypeColor(type) {
  const map = { 'CT': 'primary', 'MRI': 'success', 'X-Ray': 'warning', 'B超': 'info', 'PET': 'danger' }
  return map[type] || 'info'
}

function examTypeColorHex(type) {
  const map = { 'CT': '#409eff', 'MRI': '#67c23a', 'X-Ray': '#e6a23c', 'B超': '#909399', 'PET': '#f56c6c' }
  return map[type] || '#909399'
}

function examPercent(count) {
  const total = stats.value.exam_count
  if (!total) return 0
  return Math.round((count / total) * 100)
}

async function loadStats() {
  try {
    const res = await api.get('/images/stats')
    stats.value = res.data
  } catch {}
}

onMounted(loadStats)
</script>

<style scoped>
.dashboard {
  padding: 4px;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

.stat-card.blue .stat-icon { color: #409eff; }
.stat-card.green .stat-icon { color: #67c23a; }
.stat-card.purple .stat-icon { color: #9c27b0; }
.stat-card.orange .stat-icon { color: #e6a23c; }

.stat-num {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.2;
}

.stat-card.blue .stat-num { color: #409eff; }
.stat-card.green .stat-num { color: #67c23a; }
.stat-card.purple .stat-num { color: #9c27b0; }
.stat-card.orange .stat-num { color: #e6a23c; }

.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 4px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}

.content-row .el-card {
  border: none;
}

.type-stats {
  padding: 8px 0;
}

.type-item {
  margin-bottom: 16px;
}

.type-label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.type-count {
  font-size: 13px;
  color: #606266;
}

.completion-chart {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 16px;
}

.progress-label {
  text-align: center;
}

.progress-num {
  font-size: 22px;
  font-weight: 700;
}

.progress-desc {
  font-size: 12px;
  color: #909399;
}

.completion-info {
  display: flex;
  gap: 20px;
  font-size: 13px;
  color: #606266;
}

.dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 6px;
}

.dot.green { background: #67c23a; }
.dot.orange { background: #e6a23c; }
</style>
