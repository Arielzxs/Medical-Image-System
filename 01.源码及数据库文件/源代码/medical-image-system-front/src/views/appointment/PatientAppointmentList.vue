<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import { useAdminStore } from "@/stores/admin";
import { cancelAppointment, getPatientAppointments } from "@/apis/appointment";
import { ElMessage, ElMessageBox } from "element-plus";
import Stomp from "stompjs";
import SockJS from "sockjs-client";

const store = useAdminStore();
const router = useRouter();
const patientId = store.getAdmin.id;

const appointments = ref([]);
const loading = ref(false);
let stompClient = null;

const fetchAppointments = async () => {
  loading.value = true;
  try {
    const res = await getPatientAppointments(patientId);
    appointments.value = res.data;
  } catch (error) {
    ElMessage.error("获取预约列表失败");
  } finally {
    loading.value = false;
  }
};

const getStatusText = (status) => {
  switch (status) {
    case "PENDING":
      return "待报道";
    case "CHECKED_IN":
      return "已报道";
    case "IN_PROGRESS":
      return "候诊中";
    case "COMPLETED":
      return "已完成";
    case "CANCELED":
      return "已取消";
    case "EXPIRED":
      return "已过期";
    default:
      return "未知";
  }
};

const getStatusType = (status) => {
  switch (status) {
    case "PENDING":
      return "warning";
    case "CHECKED_IN":
      return "info";
    case "IN_PROGRESS":
      return "primary";
    case "COMPLETED":
      return "success";
    case "CANCELED":
      return "danger";
    case "EXPIRED":
      return "info";
    default:
      return "info";
  }
};

const handleCancelAppointment = (id) => {
  ElMessageBox.confirm("您确定要取消这个预约吗？", "取消确认", {
    confirmButtonText: "确定",
    cancelButtonText: "再想想",
    type: "warning",
  })
    .then(async () => {
      try {
        await cancelAppointment(id);
        ElMessage.success("预约已成功取消");
        fetchAppointments(); // Immediately refetch to update UI
      } catch (error) {
        ElMessage.error("取消失败，请稍后再试");
      }
    })
    .catch(() => {
      ElMessage.info("已取消操作");
    });
};

const connectWebSocket = () => {
  const socket = new SockJS("/api/ws");
  stompClient = Stomp.over(socket);

  const headers = {
    token: store.getToken,
  };

  stompClient.connect(
    headers,
    () => {
      stompClient.subscribe("/topic/appointments", () => {
        ElMessage.info("您的预约列表有更新");
        fetchAppointments();
      });
      // Also subscribe to the check-in list topic to get updates when appointments are cancelled
      stompClient.subscribe("/topic/checkin-list", () => {
        fetchAppointments();
      });
    },
    (error) => {
      console.error("WebSocket Connection Error:", error);
      ElMessage.error("实时预约服务连接失败，请刷新页面重试");
    }
  );
};

const goToCreate = () => {
  router.push("/appointment/patient");
};

onMounted(() => {
  fetchAppointments();
  connectWebSocket();
});

onUnmounted(() => {
  if (stompClient) {
    stompClient.disconnect();
  }
});
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <span>我的预约</span>
          <el-button
            type="primary"
            @click="goToCreate"
            style="margin-left: auto"
            >新建预约</el-button
          >
        </div>
      </template>
      <el-table :data="appointments" v-loading="loading" scrollbar-always-on>
        <el-table-column
          prop="appointmentDate"
          label="预约日期"
        ></el-table-column>
        <el-table-column prop="startTime" label="预约时间"></el-table-column>
        <el-table-column
          prop="appointmentContent"
          label="预约内容"
        ></el-table-column>
        <el-table-column
          prop="submissionTime"
          label="提交时间"
        ></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag
              :type="getStatusType(scope.row.status)"
              disable-transitions
              >{{ getStatusText(scope.row.status) }}</el-tag
            >
          </template>
        </el-table-column>
        <el-table-column label="操作">
          <template #default="scope">
            <el-button
              size="small"
              type="danger"
              @click="handleCancelAppointment(scope.row.id)"
              :disabled="
                scope.row.status === 'CANCELED' ||
                scope.row.status === 'COMPLETED' ||
                scope.row.status === 'EXPIRED'
              "
              >取消预约</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 18px;
  font-weight: 500;
}
</style>
