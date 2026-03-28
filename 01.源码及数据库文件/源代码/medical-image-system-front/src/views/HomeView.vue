<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { useAdminStore } from "@/stores/admin";
import { useRouter } from "vue-router";
import { getDashboardStats, getRecentActivities } from "@/apis/dashboard";
import {
  ElRow,
  ElCol,
  ElCard,
  ElStatistic,
  ElButton,
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
  Bell,
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

const navigateTo = (path) => {
  router.push(path);
};

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
    <el-card class="welcome-card" shadow="hover">
      <div class="welcome-content">
        <div class="welcome-text">
          <h2>下午好, {{ admin.username }}!</h2>
          <p>欢迎回到医疗影像管理系统。祝您有美好的一天！</p>
        </div>
      </div>
    </el-card>

    <div v-if="userRole === 'admin'">
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <el-card shadow="hover">
            <el-statistic :value="stats.totalUsers">
              <template #title>
                <div class="statistic-title">
                  <el-icon><User /></el-icon><span>系统用户总数</span>
                </div>
              </template>
            </el-statistic>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover">
            <el-statistic :value="stats.totalReports">
              <template #title>
                <div class="statistic-title">
                  <el-icon><DocumentChecked /></el-icon
                  ><span>系统报告总数</span>
                </div>
              </template>
            </el-statistic>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover">
            <el-statistic :value="stats.totalImages">
              <template #title>
                <div class="statistic-title">
                  <el-icon><IconPicture /></el-icon><span>系统影像总数</span>
                </div>
              </template>
            </el-statistic>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover">
            <el-statistic :value="stats.newMessages">
              <template #title>
                <div class="statistic-title">
                  <el-icon><Message /></el-icon><span>未读消息</span>
                </div>
              </template>
            </el-statistic>
          </el-card>
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :span="16">
          <el-card class="quick-links-card" shadow="hover">
            <template #header
              ><div class="card-header"><span>快捷操作</span></div></template
            >
            <div class="quick-links">
              <el-button
                type="primary"
                :icon="UploadFilled"
                size="large"
                @click="navigateTo('/app/image-upload')"
                >上传影像</el-button
              >
              <el-button
                type="success"
                :icon="Search"
                size="large"
                @click="navigateTo('/app/image-search')"
                >查询影像</el-button
              >
              <el-button
                type="info"
                :icon="Document"
                size="large"
                @click="navigateTo('/report/management')"
                >报告管理</el-button
              >
              <el-button
                type="warning"
                :icon="Message"
                size="large"
                @click="navigateTo('/messages')"
                >消息中心</el-button
              >
            </div>
          </el-card>

          <el-card class="carousel-card" shadow="hover">
            <template #header
              ><div class="card-header"><span>系统公告</span></div></template
            >
            <el-carousel height="280px">
              <el-carousel-item
                v-for="(item, index) in [
                  carouselImage1,
                  carouselImage2,
                  carouselImage3,
                  carouselImage4,
                ]"
                :key="index"
              >
                <img :src="item" class="carousel-image" />
              </el-carousel-item>
            </el-carousel>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="activity-card" shadow="hover">
            <template #header
              ><div class="card-header"><span>最近活动</span></div></template
            >
            <el-timeline>
              <el-timeline-item
                v-for="(activity, index) in activities"
                :key="index"
                :timestamp="activity.timestamp"
                :type="activity.type"
                placement="top"
              >
                <p>{{ activity.content }}</p>
              </el-timeline-item>
            </el-timeline>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <div v-else-if="['doctor', 'expert'].includes(userRole)">
      <el-row :gutter="20" class="stats-row">
        <el-col :span="8"
          ><el-card shadow="hover"
            ><el-statistic :value="stats.totalImages"
              ><template #title
                ><div class="statistic-title">
                  <el-icon><UploadFilled /></el-icon><span>我上传的影像</span>
                </div></template
              ></el-statistic
            ></el-card
          ></el-col
        >
        <el-col :span="8"
          ><el-card shadow="hover"
            ><el-statistic :value="stats.totalReports"
              ><template #title
                ><div class="statistic-title">
                  <el-icon><DocumentChecked /></el-icon
                  ><span>我创建的报告</span>
                </div></template
              ></el-statistic
            ></el-card
          ></el-col
        >
        <el-col :span="8"
          ><el-card shadow="hover"
            ><el-statistic :value="stats.newMessages"
              ><template #title
                ><div class="statistic-title">
                  <el-icon><Message /></el-icon><span>未读消息</span>
                </div></template
              ></el-statistic
            ></el-card
          ></el-col
        >
      </el-row>
      <el-card class="quick-links-card" shadow="hover">
        <template #header
          ><div class="card-header"><span>快捷操作</span></div></template
        >
        <div class="quick-links">
          <el-button
            type="primary"
            :icon="UploadFilled"
            size="large"
            @click="navigateTo('/app/image-upload')"
            >上传影像</el-button
          >
          <el-button
            type="success"
            :icon="Search"
            size="large"
            @click="navigateTo('/app/image-search')"
            >查询影像</el-button
          >
          <el-button
            type="info"
            :icon="Document"
            size="large"
            @click="navigateTo('/report/management')"
            >报告管理</el-button
          >
          <el-button
            type="warning"
            :icon="Message"
            size="large"
            @click="navigateTo('/messages')"
            >消息中心</el-button
          >
        </div>
      </el-card>
    </div>

    <div v-else-if="userRole === 'patient'">
      <el-row :gutter="20" class="stats-row">
        <el-col :span="8"
          ><el-card shadow="hover"
            ><el-statistic :value="stats.totalImages"
              ><template #title
                ><div class="statistic-title">
                  <el-icon><Tickets /></el-icon><span>我的影像</span>
                </div></template
              ></el-statistic
            ></el-card
          ></el-col
        >
        <el-col :span="8"
          ><el-card shadow="hover"
            ><el-statistic :value="stats.totalReports"
              ><template #title
                ><div class="statistic-title">
                  <el-icon><DocumentChecked /></el-icon><span>我的报告</span>
                </div></template
              ></el-statistic
            ></el-card
          ></el-col
        >
        <el-col :span="8"
          ><el-card shadow="hover"
            ><el-statistic :value="stats.newMessages"
              ><template #title
                ><div class="statistic-title">
                  <el-icon><Message /></el-icon><span>未读消息</span>
                </div></template
              ></el-statistic
            ></el-card
          ></el-col
        >
      </el-row>
      <el-card class="quick-links-card" shadow="hover">
        <template #header
          ><div class="card-header"><span>常用功能</span></div></template
        >
        <div class="quick-links">
          <el-button
            type="primary"
            :icon="Search"
            size="large"
            @click="navigateTo('/app/image-search')"
            >查看我的影像</el-button
          >
          <el-button
            type="warning"
            :icon="Message"
            size="large"
            @click="navigateTo('/messages')"
            >消息中心</el-button
          >
          <el-button
            type="info"
            :icon="User"
            size="large"
            @click="navigateTo('/user/profile')"
            >个人信息</el-button
          >
        </div>
      </el-card>
    </div>
  </div>
</template>

<style scoped>
.home-container {
  padding: 20px;
  background-color: #f0f2f5;
}
.welcome-card {
  margin-bottom: 20px;
  background-color: #e6f7ff;
  border: 1px solid #91d5ff;
}
.welcome-content {
  display: flex;
  align-items: center;
}
.welcome-img {
  width: 120px;
  height: 120px;
  margin-right: 20px;
}
.welcome-text h2 {
  margin: 0;
  font-size: 24px;
  color: #0d84ff;
}
.welcome-text p {
  margin: 5px 0 0;
  color: #595959;
}
.stats-row {
  margin-bottom: 20px;
}
.statistic-title {
  display: flex;
  align-items: center;
  font-size: 16px;
  color: #595959;
}
.statistic-title .el-icon {
  margin-right: 8px;
}
.card-header {
  font-size: 18px;
  font-weight: 500;
  display: flex;
  align-items: center;
}
.quick-links-card .quick-links {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}
.activity-card {
  /* 让活动卡片填满父容器的高度 */
  height: 100%;
}
.activity-card .el-timeline {
  padding-left: 10px;
}

/* 为轮播图卡片添加样式 */
.carousel-card {
  margin-top: 20px;
}

.carousel-image {
  width: 100%;
  height: 100%;
  object-fit: cover; /* 确保图片覆盖整个容器，不变形 */
  border-radius: 4px; /* 轻微的圆角 */
}
</style>
