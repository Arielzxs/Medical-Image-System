<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import { getWaitingList, completeAppointment } from "@/apis/appointment";
import { ElMessage } from "element-plus";
import Stomp from "stompjs";
import SockJS from "sockjs-client";
import { useAdminStore } from "@/stores/admin";

const store = useAdminStore();
const waitingList = ref([]);
const loadingWaiting = ref(false);
let stompClient = null;

const fetchWaitingList = async () => {
  loadingWaiting.value = true;
  try {
    const res = await getWaitingList();
    waitingList.value = res.data;
  } catch (error) {
    ElMessage.error("获取候诊列表失败");
  } finally {
    loadingWaiting.value = false;
  }
};

const handleComplete = async (id) => {
  try {
    await completeAppointment(id);
    ElMessage.success("操作成功");
  } catch (error) {
    ElMessage.error("操作失败");
  }
};

const connectWebSocket = () => {
  const socket = new SockJS("/api/ws");
  stompClient = Stomp.over(socket);
  const headers = { token: store.getToken };

  stompClient.connect(
    headers,
    () => {
      stompClient.subscribe("/topic/waiting-list", () => {
        ElMessage.info("候诊列表有更新");
        fetchWaitingList();
      });
    },
    (error) => {
      console.error("WebSocket Connection Error:", error);
      ElMessage.error("实时服务连接失败，请刷新页面重试");
    }
  );
};

onMounted(() => {
  fetchWaitingList();
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
          <span>候诊列表</span>
        </div>
      </template>
      <el-table :data="waitingList" v-loading="loadingWaiting">
        <el-table-column prop="checkInTime" label="报道时间"></el-table-column>
        <el-table-column prop="patientName" label="患者姓名"></el-table-column>
        <el-table-column
          prop="appointmentContent"
          label="预约内容"
        ></el-table-column>
        <el-table-column label="操作">
          <template #default="scope">
            <el-button
              size="small"
              type="primary"
              @click="handleComplete(scope.row.id)"
              >完成</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>
