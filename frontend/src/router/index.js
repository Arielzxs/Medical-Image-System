import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/store/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/views/LayoutView.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: '/dashboard'
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/DashboardView.vue'),
        meta: { title: '工作台', icon: 'DataAnalysis' }
      },
      {
        path: 'patients',
        name: 'Patients',
        component: () => import('@/views/PatientListView.vue'),
        meta: { title: '患者管理', icon: 'User' }
      },
      {
        path: 'patients/:id',
        name: 'PatientDetail',
        component: () => import('@/views/PatientDetailView.vue'),
        meta: { title: '患者详情', icon: 'User' }
      },
      {
        path: 'examinations',
        name: 'Examinations',
        component: () => import('@/views/ExaminationListView.vue'),
        meta: { title: '检查管理', icon: 'Document' }
      },
      {
        path: 'examinations/:id',
        name: 'ExaminationDetail',
        component: () => import('@/views/ExaminationDetailView.vue'),
        meta: { title: '检查详情', icon: 'Document' }
      },
      {
        path: 'images',
        name: 'Images',
        component: () => import('@/views/ImageListView.vue'),
        meta: { title: '影像管理', icon: 'Picture' }
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/UserManageView.vue'),
        meta: { title: '用户管理', icon: 'Setting', adminOnly: true }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  if (to.meta.requiresAuth !== false && !authStore.token) {
    next('/login')
  } else if (to.path === '/login' && authStore.token) {
    next('/')
  } else {
    next()
  }
})

export default router
