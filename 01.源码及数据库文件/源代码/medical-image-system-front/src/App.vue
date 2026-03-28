<script setup>
import { reactive, computed } from "vue";
import { useRouter } from "vue-router";
import Header from "@/components/Header.vue";
import Footer from "@/components/Footer.vue";
import { useAdminStore } from "@/stores/admin";
import {
  Odometer,
  UploadFilled,
  Search,
  Document,
  User,
  Setting,
  PictureFilled,
  DocumentChecked,
  Message,
  ChatDotRound,
  Tickets,
  Files,
  Camera,
  Calendar,
  DataLine,
  Plus,
} from "@element-plus/icons-vue";

const store = useAdminStore();
const noMenu = ["/login", "/register"];
const router = useRouter();
const dataInfo = reactive({
  showMenu: true,
  defaultOpen: ["1", "2", "3", "4", "5", "6", "7"], // 默认展开所有子菜单
  currentPath: "/",
});

// 获取当前用户的角色
const userRole = computed(() => store.getAdmin.role);

// 全局前置路由守卫，用于权限控制和菜单状态更新
router.beforeEach((to, from, next) => {
  if (noMenu.includes(to.path)) {
    next();
  } else {
    if (!store.getToken || store.getToken == "") {
      next({ path: "/login" });
    } else {
      next();
    }
  }
  dataInfo.showMenu = !noMenu.includes(to.path);
  dataInfo.currentPath = to.path;
});
</script>

<template>
  <div class="layout">
    <el-container v-if="dataInfo.showMenu" class="container">
      <el-aside class="aside">
        <div class="head">
          <div>
            <span class="app-title">医疗影像系统</span>
          </div>
        </div>
        <el-menu
          background-color="#304156"
          text-color="#bfcbd9"
          active-text-color="#409EFF"
          :router="true"
          :default-openeds="dataInfo.defaultOpen"
          :default-active="dataInfo.currentPath"
        >
          <el-menu-item index="/home">
            <el-icon><Odometer /></el-icon>
            <span>首页</span>
          </el-menu-item>

          <el-sub-menu index="7">
            <template #title>
              <el-icon><Calendar /></el-icon>
              <span>预约管理</span>
            </template>
            <el-menu-item
              index="/appointment/check-in"
              v-if="['doctor', 'expert', 'admin'].includes(userRole)"
            >
              <el-icon><DataLine /></el-icon>
              <span>报道列表</span>
            </el-menu-item>
            <el-menu-item
              index="/appointment/waiting-list"
              v-if="['doctor', 'expert', 'admin'].includes(userRole)"
            >
              <el-icon><DataLine /></el-icon>
              <span>候诊列表</span>
            </el-menu-item>
            <el-menu-item index="/appointment/patient">
              <el-icon><Plus /></el-icon>
              <span>新建预约</span>
            </el-menu-item>
            <el-menu-item index="/appointment/list">
              <el-icon><Tickets /></el-icon>
              <span>我的预约</span>
            </el-menu-item>
          </el-sub-menu>

          <el-sub-menu
            index="1"
            v-if="['patient', 'doctor', 'expert', 'admin'].includes(userRole)"
          >
            <template #title>
              <el-icon><PictureFilled /></el-icon>
              <span>影像管理</span>
            </template>
            <el-menu-item index="/app/image-upload">
              <el-icon><UploadFilled /></el-icon>
              <span>影像上传</span>
            </el-menu-item>
            <el-menu-item index="/app/image-search">
              <el-icon><Search /></el-icon>
              <span>影像查询</span>
            </el-menu-item>
          </el-sub-menu>

          <el-sub-menu
            index="5"
            v-if="['doctor', 'expert', 'admin'].includes(userRole)"
          >
            <template #title>
              <el-icon><DocumentChecked /></el-icon>
              <span>报告管理</span>
            </template>
            <el-menu-item index="/report/create">
              <el-icon><Document /></el-icon>
              <span>创建报告</span>
            </el-menu-item>
            <el-menu-item index="/report/query">
              <el-icon><Search /></el-icon>
              <span>查询报告</span>
            </el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="2">
            <template #title>
              <el-icon><Message /></el-icon>
              <span>交流中心</span>
            </template>
            <el-menu-item index="/messages">
              <el-icon><ChatDotRound /></el-icon>
              <span>我的对话</span>
            </el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="6">
            <template #title>
              <el-icon><ChatDotRound /></el-icon>
              <span>智能助手</span>
            </template>
            <el-menu-item index="/ai/chat">
              <el-icon><ChatDotRound /></el-icon>
              <span>AI 问答</span>
            </el-menu-item>
            <el-menu-item index="/ai/multi-image-analysis">
              <el-icon><Picture /></el-icon>
              <span>多影像分析</span>
            </el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="3" v-if="userRole === 'admin'">
            <template #title>
              <el-icon><Setting /></el-icon>
              <span>系统管理</span>
            </template>
            <el-menu-item index="/admin/page">
              <el-icon><User /></el-icon>
              <span>用户管理</span>
            </el-menu-item>
            <el-menu-item index="/log/operation">
              <el-icon><Files /></el-icon>
              <span>操作日志</span>
            </el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="4">
            <template #title>
              <el-icon><User /></el-icon>
              <span>个人中心</span>
            </template>
            <el-menu-item index="/user/profile">
              <el-icon><Setting /></el-icon>
              <span>个人信息</span>
            </el-menu-item>
          </el-sub-menu>
        </el-menu>
      </el-aside>

      <el-container class="content">
        <Header />
        <div class="main">
          <router-view />
        </div>
        <Footer />
      </el-container>
    </el-container>

    <el-container v-else class="container">
      <router-view />
    </el-container>
  </div>
</template>

<style scoped>
.layout {
  min-height: 100vh;
  background-color: #f7f9fc; /* 更柔和的背景色 */
  font-family: "Helvetica Neue", Helvetica, "PingFang SC", "Hiragino Sans GB",
    "Microsoft YaHei", Arial, sans-serif;
}
.container {
  height: 100vh;
}
.aside {
  width: 220px !important;
  background-color: #2c3e50; /* 更深邃的侧边栏颜色 */
  box-shadow: 2px 0 8px rgba(0, 21, 41, 0.1);
  transition: width 0.3s;
}
.head {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 64px; /* 增加高度 */
  padding: 0 15px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}
.app-title {
  font-size: 24px;
  color: #ecf0f1;
  font-weight: 500;
  white-space: nowrap;
}
.content {
  display: flex;
  flex-direction: column;
  max-height: 100vh;
  overflow: hidden;
  background-color: #f7f9fc;
}
.main {
  flex: 1;
  overflow: auto;
  padding: 24px;
}
</style>

<style>
/* 全局 Element Plus 组件样式覆盖 */
.el-menu {
  border-right: none !important;
}
.el-sub-menu__title,
.el-menu-item {
  color: #bdc3c7 !important;
  font-weight: 500;
}
.el-menu-item.is-active {
  background-color: #3498db !important;
  color: #fff !important;
  border-right: 3px solid #5dade2;
}
.el-sub-menu__title:hover,
.el-menu-item:hover {
  background-color: #34495e !important;
  color: #fff !important;
}
.el-button {
  border-radius: 6px !important; /* 更圆润的按钮 */
}
.el-card {
  border: 1px solid #e6e9ed;
  border-radius: 8px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
  margin-bottom: 24px;
}
.el-table th.el-table__cell {
  background-color: #f8f9fa !important;
  color: #343a40;
  font-weight: 600;
}
</style>
