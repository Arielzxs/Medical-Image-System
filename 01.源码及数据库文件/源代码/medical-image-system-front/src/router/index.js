import { createRouter, createWebHistory } from "vue-router";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/login",
      name: "login",
      component: () => import("@/views/LoginView.vue"),
    },
    {
      path: "/register",
      name: "register",
      component: () => import("@/views/RegisterView.vue"),
    },
    {
      path: "/home",
      name: "home",
      component: () => import("@/views/HomeView.vue"),
    },
    {
      path: "/app/image-upload",
      name: "imageUpload",
      component: () => import("@/views/image/ImageUpload.vue"),
    },
    {
      path: "/app/image-search",
      name: "imageSearch",
      component: () => import("@/views/image/ImageSearch.vue"),
    },
    {
      path: "/report/create",
      name: "reportCreate",
      component: () => import("@/views/report/CreateReport.vue"),
    },
    {
      path: "/report/query",
      name: "reportQuery",
      component: () => import("@/views/report/QueryReport.vue"),
    },
    {
      path: "/user/profile",
      name: "userProfile",
      component: () => import("@/views/user/ProfileManagement.vue"),
    },
    {
      path: "/messages",
      name: "messageCenter",
      component: () => import("@/views/message/MessageCenter.vue"),
    },
    {
      path: "/admin/page",
      name: "adminPage",
      component: () => import("@/views/admin/AdminPageView.vue"),
    },
    {
      path: "/admin/add",
      name: "adminAdd",
      component: () => import("@/views/admin/AdminAdd.vue"),
    },
    {
      path: "/admin/edit",
      name: "adminEdit",
      component: () => import("@/views/admin/AdminEdit.vue"),
    },
    {
      path: "/log/operation",
      name: "operationLog",
      component: () => import("@/views/log/OperationLog.vue"),
    },
    {
      path: "/ai/chat",
      name: "aiChat",
      component: () => import("@/views/ai/Chat.vue"),
    },
    {
      path: "/ai/multi-image-analysis",
      name: "aiMultiImageAnalysis",
      component: () => import("@/views/ai/MultiImageAnalysis.vue"),
    },
    {
      path: "/appointment/patient",
      name: "patientAppointment",
      component: () => import("@/views/appointment/CreateAppointment.vue"),
    },
    {
      path: "/appointment/list",
      name: "patientAppointmentList",
      component: () => import("@/views/appointment/PatientAppointmentList.vue"),
    },
    {
      path: "/appointment/check-in",
      name: "checkInList",
      component: () => import("@/views/appointment/CheckInList.vue"),
    },
    {
      path: "/appointment/waiting-list",
      name: "waitingList",
      component: () => import("@/views/appointment/WaitingList.vue"),
    },
  ],
});

export default router;
