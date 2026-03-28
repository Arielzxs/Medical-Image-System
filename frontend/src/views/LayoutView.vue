<template>
  <el-container class="layout-container">
    <!-- Sidebar -->
    <el-aside :width="isCollapsed ? '64px' : '220px'" class="sidebar">
      <div class="sidebar-logo">
        <el-icon :size="24" color="#fff"><FirstAidKit /></el-icon>
        <span v-if="!isCollapsed" class="logo-text">医疗影像系统</span>
      </div>

      <el-menu
        :default-active="activeMenu"
        background-color="#001529"
        text-color="#ccc"
        active-text-color="#fff"
        :collapse="isCollapsed"
        :collapse-transition="false"
        router
      >
        <el-menu-item index="/dashboard">
          <el-icon><DataAnalysis /></el-icon>
          <template #title>工作台</template>
        </el-menu-item>

        <el-menu-item index="/patients">
          <el-icon><User /></el-icon>
          <template #title>患者管理</template>
        </el-menu-item>

        <el-menu-item index="/examinations">
          <el-icon><Document /></el-icon>
          <template #title>检查管理</template>
        </el-menu-item>

        <el-menu-item index="/images">
          <el-icon><Picture /></el-icon>
          <template #title>影像管理</template>
        </el-menu-item>

        <el-menu-item v-if="authStore.isAdmin" index="/users">
          <el-icon><Setting /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- Main content -->
    <el-container class="main-container">
      <!-- Header -->
      <el-header class="header">
        <div class="header-left">
          <el-button
            :icon="isCollapsed ? Expand : Fold"
            circle
            size="small"
            @click="isCollapsed = !isCollapsed"
          />
          <el-breadcrumb separator="/" class="breadcrumb">
            <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="currentTitle">{{ currentTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <div class="user-info">
              <el-avatar :size="32" :icon="UserFilled" />
              <span class="user-name">{{ authStore.user?.real_name || authStore.user?.username }}</span>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon> 个人信息
                </el-dropdown-item>
                <el-dropdown-item divided command="logout">
                  <el-icon><SwitchButton /></el-icon> 退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- Main -->
      <el-main>
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" :key="$route.path" />
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </el-container>

  <!-- Profile Dialog -->
  <el-dialog v-model="profileVisible" title="个人信息" width="400px">
    <el-form :model="profileForm" label-width="80px">
      <el-form-item label="用户名">
        <el-input :value="authStore.user?.username" disabled />
      </el-form-item>
      <el-form-item label="真实姓名">
        <el-input v-model="profileForm.real_name" />
      </el-form-item>
      <el-form-item label="科室">
        <el-input v-model="profileForm.department" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="profileVisible = false">取消</el-button>
      <el-button type="primary" @click="saveProfile">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, reactive, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Expand, Fold, UserFilled, ArrowDown } from '@element-plus/icons-vue'
import { useAuthStore } from '@/store/auth'
import api from '@/api'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const isCollapsed = ref(false)
const profileVisible = ref(false)
const profileForm = reactive({ real_name: '', department: '' })

const activeMenu = computed(() => '/' + route.path.split('/')[1])
const currentTitle = computed(() => route.meta?.title || '')

async function handleCommand(cmd) {
  if (cmd === 'profile') {
    profileForm.real_name = authStore.user?.real_name || ''
    profileForm.department = authStore.user?.department || ''
    profileVisible.value = true
  } else if (cmd === 'logout') {
    await ElMessageBox.confirm('确认退出登录吗？', '提示', { type: 'warning' })
    authStore.logout()
    router.push('/login')
    ElMessage.success('已退出登录')
  }
}

async function saveProfile() {
  try {
    await api.put('/auth/profile', profileForm)
    const u = { ...authStore.user, ...profileForm }
    authStore.setAuth(authStore.token, u)
    ElMessage.success('保存成功')
    profileVisible.value = false
  } catch {}
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.sidebar {
  background-color: #001529;
  transition: width 0.3s;
  overflow: hidden;
}

.sidebar-logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  border-bottom: 1px solid rgba(255,255,255,0.1);
  padding: 0 16px;
  overflow: hidden;
}

.logo-text {
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  white-space: nowrap;
}

.el-menu {
  border-right: none;
}

.header {
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0,21,41,0.08);
  height: 60px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.breadcrumb {
  font-size: 14px;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background 0.2s;
}

.user-info:hover {
  background: #f5f7fa;
}

.user-name {
  font-size: 14px;
  color: #333;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.el-main {
  padding: 20px;
  overflow-y: auto;
  background: #f5f7fa;
}
</style>
