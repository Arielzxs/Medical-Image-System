<template>
  <div class="header">
    <div class="left">
      <el-icon class="back-icon" v-if="state.hasBack" @click="back">
        <Back />
      </el-icon>
      <div class="page-info">
        <span class="welcome-text">欢迎回来, <strong>{{ store.getAdmin.username }}</strong></span>
        <span class="role-badge">{{ roleLabel }}</span>
      </div>
    </div>
    <div class="center">
      <div class="search-bar">
        <el-icon class="search-icon"><Search /></el-icon>
        <input type="text" placeholder="搜索..." class="search-input" />
      </div>
    </div>
    <div class="right-controls">
      <el-popover placement="bottom" :width="340" trigger="click">
        <template #reference>
          <div class="action-item" title="通知">
            <el-badge
              :value="unreadCount"
              :hidden="unreadCount === 0"
              class="item"
            >
              <el-icon :size="20"><Bell /></el-icon>
            </el-badge>
          </div>
        </template>
        <div class="notification-panel">
          <div class="notification-header">
            <span class="notification-title">通知中心</span>
            <span class="notification-count">{{ unreadCount }} 条未读</span>
          </div>
          <div v-if="notifications.length > 0">
            <div
              v-for="n in notifications"
              :key="n.id"
              class="notification-item"
              @click="handleNotificationClick(n)"
            >
              <div class="notification-dot"></div>
              <div class="notification-content">
                <p class="notification-message">{{ n.message }}</p>
                <span class="notification-time">{{ n.createdAt }}</span>
              </div>
            </div>
          </div>
          <el-empty v-else description="暂无通知" :image-size="60" />
        </div>
      </el-popover>

      <div class="divider-v"></div>

      <el-dropdown class="action-item" @command="handleCommand">
        <span class="el-dropdown-link">
          <el-avatar :size="34" class="user-avatar">{{
            store.getAdmin.username ? store.getAdmin.username[0].toUpperCase() : ""
          }}</el-avatar>
          <div class="user-info">
            <span class="username">{{ store.getAdmin.username || "" }}</span>
          </div>
          <el-icon class="el-icon--right arrow-icon"><arrow-down /></el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item :icon="User" command="profile"
              >个人中心</el-dropdown-item
            >
            <el-dropdown-item :icon="SwitchButton" command="logout" divided
              >退出登录</el-dropdown-item
            >
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup>
import { reactive, onMounted, onUnmounted, ref, computed } from "vue";
import { useRouter } from "vue-router";
import { useAdminStore } from "@/stores/admin";
import { getUserNotifications, markAsRead } from "@/apis/notification";
import { ElMessage } from "element-plus";
import Stomp from "stompjs";
import SockJS from "sockjs-client";
import {
  Bell,
  Back,
  ArrowDown,
  User,
  Setting,
  SwitchButton,
  Search,
} from "@element-plus/icons-vue";

const store = useAdminStore();
const router = useRouter();
const notifications = ref([]);
const unreadCount = computed(() => notifications.value.length);
let stompClient = null;
const state = reactive({
  hasBack: false,
});

const roleLabel = computed(() => {
  const roleMap = {
    admin: "管理员",
    doctor: "医生",
    expert: "专家",
    patient: "患者",
  };
  return roleMap[store.getAdmin.role] || "";
});

const fetchNotifications = async () => {
  if (store.getAdmin.id && store.getToken) {
    try {
      const res = await getUserNotifications(store.getAdmin.id);
      notifications.value = res.data;
    } catch (error) {
      console.error("获取通知失败:", error);
    }
  }
};

const connectWebSocket = () => {
  if (!store.getToken) {
    return;
  }

  const socket = new SockJS("/api/ws");
  stompClient = Stomp.over(socket);
  const headers = {
    token: store.getToken,
  };

  stompClient.connect(
    headers,
    () => {
      stompClient.subscribe(
        `/user/${store.getAdmin.id}/queue/notifications`,
        () => {
          ElMessage.info("您有新的通知");
          fetchNotifications();
        }
      );
    },
    (error) => {
      console.error("WebSocket 连接错误:", error);
    }
  );
};

onMounted(() => {
  if (store.getAdmin.id && store.getToken) {
    fetchNotifications();
    connectWebSocket();
  }
});

onUnmounted(() => {
  if (stompClient && stompClient.connected) {
    stompClient.disconnect(() => {
      console.log("Header WebSocket 已断开连接。");
    });
  }
});

const handleNotificationClick = async (notification) => {
  await markAsRead(notification.id);
  await fetchNotifications();
  router.push({ path: "/messages" });
};

const handleCommand = (command) => {
  switch (command) {
    case "profile":
      router.push({ path: "/user/profile" });
      break;
    case "logout":
      if (stompClient && stompClient.connected) {
        stompClient.disconnect();
      }
      store.saveToken("");
      store.saveAdmin({});
      window.location.href = "/login";
      break;
  }
};

router.afterEach((to) => {
  state.hasBack = ["level2", "level3"].includes(to.name);
});

const back = () => {
  router.back();
};
</script>

<style scoped>
.header {
  height: 64px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px;
  background-color: #ffffff;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.06);
  position: relative;
  z-index: 10;
  flex-shrink: 0;
}

.left {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 200px;
}

.back-icon {
  cursor: pointer;
  font-size: 20px;
  color: #4a5568;
}

.page-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.welcome-text {
  font-size: 14px;
  color: #4a5568;
}

.welcome-text strong {
  color: #1a2b45;
}

.role-badge {
  font-size: 11px;
  padding: 2px 8px;
  background: #e8f4ff;
  color: #1890ff;
  border-radius: 10px;
  font-weight: 600;
}

.center {
  flex: 1;
  display: flex;
  justify-content: center;
  padding: 0 40px;
}

.search-bar {
  display: flex;
  align-items: center;
  background: #f5f7fa;
  border: 1px solid #e8ecf0;
  border-radius: 22px;
  padding: 6px 16px;
  width: 320px;
  transition: all 0.25s;
}

.search-bar:focus-within {
  border-color: #1890ff;
  background: #fff;
  box-shadow: 0 0 0 2px rgba(24, 144, 255, 0.1);
}

.search-icon {
  color: #9baab8;
  font-size: 16px;
  margin-right: 8px;
}

.search-input {
  border: none;
  outline: none;
  background: transparent;
  font-size: 13px;
  color: #4a5568;
  width: 100%;
}

.search-input::placeholder {
  color: #b0bec5;
}

.right-controls {
  display: flex;
  align-items: center;
  gap: 20px;
  min-width: 200px;
  justify-content: flex-end;
}

.action-item {
  cursor: pointer;
  display: flex;
  align-items: center;
  color: #4a5568;
  transition: color 0.2s;
}

.action-item:hover {
  color: #1890ff;
}

.divider-v {
  width: 1px;
  height: 24px;
  background: #e8ecf0;
}

.el-dropdown-link {
  display: flex;
  align-items: center;
  gap: 8px;
  outline: none;
  cursor: pointer;
}

.user-avatar {
  background: linear-gradient(135deg, #1890ff 0%, #36cfc9 100%);
  color: #fff;
  font-size: 14px;
  font-weight: 700;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.username {
  font-size: 14px;
  font-weight: 600;
  color: #1a2b45;
}

.arrow-icon {
  font-size: 12px;
  color: #9baab8;
}

.notification-panel {
  max-height: 380px;
  overflow-y: auto;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 4px;
}

.notification-title {
  font-size: 14px;
  font-weight: 600;
  color: #1a2b45;
}

.notification-count {
  font-size: 12px;
  color: #1890ff;
  background: #e8f4ff;
  padding: 2px 8px;
  border-radius: 10px;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  padding: 12px 16px;
  cursor: pointer;
  border-bottom: 1px solid #f7f8fa;
  gap: 10px;
  transition: background 0.15s;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-item:hover {
  background-color: #f0f7ff;
}

.notification-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #1890ff;
  margin-top: 5px;
  flex-shrink: 0;
}

.notification-content {
  flex: 1;
}

.notification-message {
  margin: 0 0 4px;
  font-size: 13px;
  color: #2d3748;
  line-height: 1.5;
}

.notification-time {
  font-size: 11px;
  color: #a0aec0;
}
</style>
