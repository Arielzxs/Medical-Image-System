<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { useAdminStore } from "@/stores/admin";
import { useRouter } from "vue-router";
import { getDashboardStats, getRecentActivities } from "@/apis/dashboard";
import {
  ElRow,
  ElCol,
  ElCard,
  ElTimeline,
  ElTimelineItem,
  ElIcon,
  ElCarousel,
  ElCarouselItem,
} from "element-plus";
import {
  UploadFilled,
  Search,
  Document,
  Message,
  User,
  Picture as IconPicture,
  DocumentChecked,
  Tickets,
} from "@element-plus/icons-vue";

// 导入轮播图所需的图片资源
import carouselImage1 from "../assets/carousel-1.png";
import carouselImage2 from "../assets/carousel-2.png";
import carouselImage3 from "../assets/carousel-3.png";
import carouselImage4 from "../assets/carousel-4.png";

const store = useAdminStore();
const router = useRouter();

const admin = computed(() => store.getAdmin);
const userId = computed(() => store.getAdmin.id);
const userRole = computed(() => store.getAdmin.role);

const stats = reactive({
  totalUsers: 0,
  totalReports: 0,
  totalImages: 0,
  newMessages: 0,
});

const activities = ref([]);

// Mock data for chart visualization
const weeklyData = ref([65, 78, 55, 82, 70, 90, 75]);
const weekDays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"];
const maxWeeklyVal = computed(() => Math.max(...weeklyData.value));

const imagingTypes = ref([
  { name: "CT扫描", count: 142, color: "#1890ff", percent: 71 },
  { name: "X光", count: 98, color: "#52c41a", percent: 49 },
  { name: "核磁共振", count: 76, color: "#722ed1", percent: 38 },
  { name: "超声波", count: 54, color: "#fa8c16", percent: 27 },
]);

const navigateTo = (path) => {
  router.push(path);
};

const greetingText = computed(() => {
  const hour = new Date().getHours();
  if (hour < 12) return "早上好";
  if (hour < 18) return "下午好";
  return "晚上好";
});

onMounted(async () => {
  if (userId.value) {
    try {
      const res = await getDashboardStats(userId.value);
      if (res.state === 0) {
        Object.assign(stats, res.data);
      }
    } catch (error) {
      console.error("获取仪表盘统计数据失败:", error);
    }
  }

  if (userRole.value === "admin") {
    try {
      const res = await getRecentActivities();
      if (res.state === 0) {
        activities.value = res.data.map((log) => ({
          content: `${log.username || "系统用户"} ${log.operation}`,
          timestamp: log.createdAt,
          type: "primary",
        }));
      }
    } catch (error) {
      console.error("获取最近活动失败:", error);
    }
  }
});
</script>

<template>
  <div class="home-container">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div class="welcome-left">
        <div class="greeting-icon">👨‍⚕️</div>
        <div class="welcome-text-block">
          <h2>{{ greetingText }}, {{ admin.username }}!</h2>
          <p>欢迎回到医疗影像管理系统，今日工作状态良好。</p>
        </div>
      </div>
      <div class="welcome-right">
        <div class="date-display">
          <div class="date-num">{{ new Date().getDate() }}</div>
          <div class="date-info">
            <span>{{ new Date().toLocaleDateString('zh-CN', { month: 'long' }) }}</span>
            <span>{{ new Date().getFullYear() }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 管理员视图 -->
    <div v-if="userRole === 'admin'">
      <!-- 统计卡片 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <div class="stat-card stat-blue">
            <div class="stat-icon">
              <el-icon :size="28"><User /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.totalUsers }}</div>
              <div class="stat-label">系统用户总数</div>
            </div>
            <div class="stat-bg-icon">👥</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card stat-green">
            <div class="stat-icon">
              <el-icon :size="28"><DocumentChecked /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.totalReports }}</div>
              <div class="stat-label">系统报告总数</div>
            </div>
            <div class="stat-bg-icon">📋</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card stat-purple">
            <div class="stat-icon">
              <el-icon :size="28"><IconPicture /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.totalImages }}</div>
              <div class="stat-label">系统影像总数</div>
            </div>
            <div class="stat-bg-icon">🖼️</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card stat-orange">
            <div class="stat-icon">
              <el-icon :size="28"><Message /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.newMessages }}</div>
              <div class="stat-label">未读消息</div>
            </div>
            <div class="stat-bg-icon">💬</div>
          </div>
        </el-col>
      </el-row>

      <!-- 图表和活动 -->
      <el-row :gutter="20">
        <el-col :span="16">
          <!-- 周度影像追踪图表 -->
          <el-card shadow="never" class="chart-card">
            <template #header>
              <div class="card-header-row">
                <span class="card-title">本周影像追踪</span>
                <div class="chart-legend">
                  <span class="legend-dot" style="background:#1890ff"></span>
                  <span class="legend-text">影像数量</span>
                </div>
              </div>
            </template>
            <div class="bar-chart">
              <div
                v-for="(val, idx) in weeklyData"
                :key="idx"
                class="bar-group"
              >
                <div class="bar-value">{{ val }}</div>
                <div
                  class="bar"
                  :style="{ height: (val / maxWeeklyVal * 140) + 'px' }"
                ></div>
                <div class="bar-label">{{ weekDays[idx] }}</div>
              </div>
            </div>
          </el-card>

          <!-- 快捷操作 -->
          <el-card shadow="never" class="quick-card">
            <template #header>
              <span class="card-title">快捷操作</span>
            </template>
            <div class="quick-links">
              <button class="quick-btn quick-btn-blue" @click="navigateTo('/app/image-upload')">
                <el-icon><UploadFilled /></el-icon>
                <span>上传影像</span>
              </button>
              <button class="quick-btn quick-btn-green" @click="navigateTo('/app/image-search')">
                <el-icon><Search /></el-icon>
                <span>查询影像</span>
              </button>
              <button class="quick-btn quick-btn-purple" @click="navigateTo('/report/management')">
                <el-icon><Document /></el-icon>
                <span>报告管理</span>
              </button>
              <button class="quick-btn quick-btn-orange" @click="navigateTo('/messages')">
                <el-icon><Message /></el-icon>
                <span>消息中心</span>
              </button>
            </div>
          </el-card>
        </el-col>

        <el-col :span="8">
          <!-- 最多需求影像类型 -->
          <el-card shadow="never" class="demand-card">
            <template #header>
              <span class="card-title">影像需求分析</span>
            </template>
            <div class="demand-list">
              <div
                v-for="item in imagingTypes"
                :key="item.name"
                class="demand-item"
              >
                <div class="demand-name-row">
                  <span class="demand-name">{{ item.name }}</span>
                  <span class="demand-count">{{ item.count }}</span>
                </div>
                <div class="demand-bar-bg">
                  <div
                    class="demand-bar-fill"
                    :style="{ width: item.percent + '%', background: item.color }"
                  ></div>
                </div>
              </div>
            </div>
          </el-card>

          <!-- 最近活动 -->
          <el-card shadow="never" class="activity-card">
            <template #header>
              <span class="card-title">最近活动</span>
            </template>
            <el-timeline>
              <el-timeline-item
                v-for="(activity, index) in activities"
                :key="index"
                :timestamp="activity.timestamp"
                :type="activity.type"
                placement="top"
              >
                <p class="activity-text">{{ activity.content }}</p>
              </el-timeline-item>
              <el-timeline-item
                v-if="activities.length === 0"
                timestamp=""
                type="info"
              >
                <p class="activity-text">暂无近期活动记录</p>
              </el-timeline-item>
            </el-timeline>
          </el-card>
        </el-col>
      </el-row>

      <!-- 系统公告轮播 -->
      <el-card shadow="never" class="carousel-card">
        <template #header>
          <span class="card-title">系统公告</span>
        </template>
        <el-carousel height="260px" indicator-position="outside">
          <el-carousel-item
            v-for="(item, index) in [carouselImage1, carouselImage2, carouselImage3, carouselImage4]"
            :key="index"
          >
            <img :src="item" class="carousel-image" />
          </el-carousel-item>
        </el-carousel>
      </el-card>
    </div>

    <!-- 医生/专家视图 -->
    <div v-else-if="['doctor', 'expert'].includes(userRole)">
      <el-row :gutter="20" class="stats-row">
        <el-col :span="8">
          <div class="stat-card stat-purple">
            <div class="stat-icon"><el-icon :size="28"><UploadFilled /></el-icon></div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.totalImages }}</div>
              <div class="stat-label">我上传的影像</div>
            </div>
            <div class="stat-bg-icon">🖼️</div>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="stat-card stat-green">
            <div class="stat-icon"><el-icon :size="28"><DocumentChecked /></el-icon></div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.totalReports }}</div>
              <div class="stat-label">我创建的报告</div>
            </div>
            <div class="stat-bg-icon">📋</div>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="stat-card stat-orange">
            <div class="stat-icon"><el-icon :size="28"><Message /></el-icon></div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.newMessages }}</div>
              <div class="stat-label">未读消息</div>
            </div>
            <div class="stat-bg-icon">💬</div>
          </div>
        </el-col>
      </el-row>
      <el-card shadow="never" class="quick-card">
        <template #header><span class="card-title">快捷操作</span></template>
        <div class="quick-links">
          <button class="quick-btn quick-btn-blue" @click="navigateTo('/app/image-upload')">
            <el-icon><UploadFilled /></el-icon><span>上传影像</span>
          </button>
          <button class="quick-btn quick-btn-green" @click="navigateTo('/app/image-search')">
            <el-icon><Search /></el-icon><span>查询影像</span>
          </button>
          <button class="quick-btn quick-btn-purple" @click="navigateTo('/report/management')">
            <el-icon><Document /></el-icon><span>报告管理</span>
          </button>
          <button class="quick-btn quick-btn-orange" @click="navigateTo('/messages')">
            <el-icon><Message /></el-icon><span>消息中心</span>
          </button>
        </div>
      </el-card>
    </div>

    <!-- 患者视图 -->
    <div v-else-if="userRole === 'patient'">
      <el-row :gutter="20" class="stats-row">
        <el-col :span="8">
          <div class="stat-card stat-blue">
            <div class="stat-icon"><el-icon :size="28"><Tickets /></el-icon></div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.totalImages }}</div>
              <div class="stat-label">我的影像</div>
            </div>
            <div class="stat-bg-icon">🖼️</div>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="stat-card stat-green">
            <div class="stat-icon"><el-icon :size="28"><DocumentChecked /></el-icon></div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.totalReports }}</div>
              <div class="stat-label">我的报告</div>
            </div>
            <div class="stat-bg-icon">📋</div>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="stat-card stat-orange">
            <div class="stat-icon"><el-icon :size="28"><Message /></el-icon></div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.newMessages }}</div>
              <div class="stat-label">未读消息</div>
            </div>
            <div class="stat-bg-icon">💬</div>
          </div>
        </el-col>
      </el-row>
      <el-card shadow="never" class="quick-card">
        <template #header><span class="card-title">常用功能</span></template>
        <div class="quick-links">
          <button class="quick-btn quick-btn-blue" @click="navigateTo('/app/image-search')">
            <el-icon><Search /></el-icon><span>查看我的影像</span>
          </button>
          <button class="quick-btn quick-btn-orange" @click="navigateTo('/messages')">
            <el-icon><Message /></el-icon><span>消息中心</span>
          </button>
          <button class="quick-btn quick-btn-green" @click="navigateTo('/user/profile')">
            <el-icon><User /></el-icon><span>个人信息</span>
          </button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<style scoped>
.home-container {
  padding: 4px 4px 24px;
  background-color: transparent;
}

/* 欢迎横幅 */
.welcome-banner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #1a2b45 0%, #1890ff 100%);
  border-radius: 14px;
  padding: 24px 30px;
  margin-bottom: 24px;
  box-shadow: 0 4px 20px rgba(24, 144, 255, 0.3);
  color: #fff;
}

.welcome-left {
  display: flex;
  align-items: center;
  gap: 18px;
}

.greeting-icon {
  font-size: 48px;
  filter: drop-shadow(0 2px 6px rgba(0,0,0,0.2));
}

.welcome-text-block h2 {
  margin: 0 0 6px;
  font-size: 22px;
  font-weight: 700;
  color: #fff;
}

.welcome-text-block p {
  margin: 0;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.8);
}

.welcome-right {
  display: flex;
  align-items: center;
}

.date-display {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 12px;
  padding: 14px 20px;
  backdrop-filter: blur(4px);
}

.date-num {
  font-size: 42px;
  font-weight: 700;
  color: #fff;
  line-height: 1;
}

.date-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.date-info span {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.85);
}

/* 统计卡片 */
.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  position: relative;
  border-radius: 12px;
  padding: 22px 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  transition: transform 0.2s, box-shadow 0.2s;
  cursor: default;
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.stat-blue { background: linear-gradient(135deg, #e8f4ff 0%, #d0e9ff 100%); }
.stat-green { background: linear-gradient(135deg, #e8fff0 0%, #d0f5e0 100%); }
.stat-purple { background: linear-gradient(135deg, #f0e8ff 0%, #e2d0ff 100%); }
.stat-orange { background: linear-gradient(135deg, #fff3e0 0%, #ffe0b0 100%); }

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-blue .stat-icon { background: #1890ff; color: #fff; }
.stat-green .stat-icon { background: #52c41a; color: #fff; }
.stat-purple .stat-icon { background: #722ed1; color: #fff; }
.stat-orange .stat-icon { background: #fa8c16; color: #fff; }

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  line-height: 1.2;
  color: #1a2b45;
}

.stat-label {
  font-size: 13px;
  color: #6b7a8d;
  margin-top: 4px;
}

.stat-bg-icon {
  position: absolute;
  right: 16px;
  bottom: 8px;
  font-size: 44px;
  opacity: 0.12;
  pointer-events: none;
}

/* 卡片标题 */
.card-title {
  font-size: 15px;
  font-weight: 600;
  color: #1a2b45;
}

.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-legend {
  display: flex;
  align-items: center;
  gap: 6px;
}

.legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.legend-text {
  font-size: 12px;
  color: #6b7a8d;
}

/* 柱状图 */
.chart-card {
  margin-bottom: 20px;
}

.bar-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  height: 180px;
  padding: 10px 0 0;
  gap: 8px;
}

.bar-group {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  gap: 6px;
}

.bar-value {
  font-size: 11px;
  color: #6b7a8d;
  font-weight: 600;
}

.bar {
  width: 100%;
  max-width: 38px;
  background: linear-gradient(180deg, #1890ff 0%, #69c0ff 100%);
  border-radius: 6px 6px 0 0;
  transition: height 0.6s ease;
  min-height: 4px;
}

.bar-label {
  font-size: 12px;
  color: #9baab8;
}

/* 快捷操作 */
.quick-card {
  margin-bottom: 20px;
}

.quick-links {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
}

.quick-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 22px;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  color: #fff;
}

.quick-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

.quick-btn-blue { background: linear-gradient(135deg, #1890ff, #40a9ff); }
.quick-btn-green { background: linear-gradient(135deg, #52c41a, #73d13d); }
.quick-btn-purple { background: linear-gradient(135deg, #722ed1, #9254de); }
.quick-btn-orange { background: linear-gradient(135deg, #fa8c16, #ffa940); }

/* 需求分析卡片 */
.demand-card {
  margin-bottom: 20px;
}

.demand-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.demand-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.demand-name-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.demand-name {
  font-size: 13px;
  color: #4a5568;
  font-weight: 500;
}

.demand-count {
  font-size: 13px;
  font-weight: 700;
  color: #1a2b45;
}

.demand-bar-bg {
  height: 8px;
  background: #f0f4f8;
  border-radius: 4px;
  overflow: hidden;
}

.demand-bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.8s ease;
}

/* 活动卡片 */
.activity-card {
  margin-bottom: 20px;
}

.activity-text {
  margin: 0;
  font-size: 13px;
  color: #4a5568;
  line-height: 1.5;
}

/* 轮播图 */
.carousel-card {
  margin-bottom: 0;
}

.carousel-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 6px;
}
</style>
