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
} from "@element-plus/icons-vue";

const store = useAdminStore();
const router = useRouter();
const notifications = ref([]);
const unreadCount = computed(() => notifications.value.length); // 因为只获取未读，所以直接用length
let stompClient = null;
const state = reactive({
  hasBack: false,
});

const fetchNotifications = async () => {
  // 增加token检查，确保只在登录状态下请求
  if (store.getAdmin.id && store.getToken) {
    try {
      const res = await getUserNotifications(store.getAdmin.id);
      notifications.value = res.data;
    } catch (error) {
      // 退出登录时可能会触发错误，这里可以静默处理
      console.error("获取通知失败:", error);
    }
  }
};

const connectWebSocket = () => {
  // 如果没有token，则不建立WebSocket连接
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
  // 在 onMounted 中同时检查ID和Token
  if (store.getAdmin.id && store.getToken) {
    fetchNotifications();
    connectWebSocket();
  }
});

// 组件卸载时，干净地断开 WebSocket 连接
onUnmounted(() => {
  if (stompClient && stompClient.connected) {
    stompClient.disconnect(() => {
      console.log("Header WebSocket 已断开连接。");
    });
  }
});

const handleNotificationClick = async (notification) => {
  await markAsRead(notification.id);
  // 跳转前先刷新一次列表，这样回到消息中心时，通知列表是干净的
  await fetchNotifications();
  router.push({ path: "/messages" });
};

const handleCommand = (command) => {
  switch (command) {
    case "profile":
      router.push({ path: "/user/profile" });
      break;
    case "logout":
      // 在跳转前确保WebSocket已断开
      if (stompClient && stompClient.connected) {
        stompClient.disconnect();
      }
      store.saveToken("");
      store.saveAdmin({}); // 同时清空用户信息
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

<template>
  <div class="header">
    <div class="left">
      <el-icon class="back-icon" v-if="state.hasBack" @click="back">
        <Back />
      </el-icon>
      <span class="welcome-text">欢迎, {{ store.getAdmin.username }}</span>
    </div>
    <div class="right-controls">
      <el-popover placement="bottom" :width="320" trigger="click">
        <template #reference>
          <div class="action-item">
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
          <div v-if="notifications.length > 0">
            <div
              v-for="n in notifications"
              :key="n.id"
              class="notification-item"
              @click="handleNotificationClick(n)"
            >
              <p class="notification-message">{{ n.message }}</p>
              <span class="notification-time">{{ n.createdAt }}</span>
            </div>
          </div>
          <el-empty v-else description="暂无通知" :image-size="60" />
        </div>
      </el-popover>

      <el-dropdown class="action-item" @command="handleCommand">
        <span class="el-dropdown-link">
          <el-avatar :size="32" class="user-avatar">{{
            store.getAdmin.username ? store.getAdmin.username[0] : ""
          }}</el-avatar>
          <span class="username">{{ store.getAdmin.username || "" }}</span>
          <el-icon class="el-icon--right"><arrow-down /></el-icon>
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

<style scoped>
.header {
  height: 64px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px;
  background-color: #ffffff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  position: relative;
  z-index: 1;
}

.left {
  display: flex;
  align-items: center;
}

.back-icon {
  cursor: pointer;
  margin-right: 16px;
  font-size: 20px;
}

.welcome-text {
  font-size: 16px;
  color: #333;
}

.right-controls {
  display: flex;
  align-items: center;
  gap: 24px;
}

.action-item {
  cursor: pointer;
  display: flex;
  align-items: center;
  color: #5a5e66;
}

.el-dropdown-link {
  display: flex;
  align-items: center;
  gap: 8px;
  outline: none;
}

.user-avatar {
  background-color: #409eff;
  color: #fff;
  font-size: 16px;
}

.notification-panel {
  max-height: 300px;
  overflow-y: auto;
}

.notification-item {
  padding: 10px 15px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-item:hover {
  background-color: #f5f5f5;
}

.notification-message {
  margin: 0 0 5px;
  font-size: 14px;
  color: #333;
}

.notification-time {
  font-size: 12px;
  color: #999;
}
</style>
