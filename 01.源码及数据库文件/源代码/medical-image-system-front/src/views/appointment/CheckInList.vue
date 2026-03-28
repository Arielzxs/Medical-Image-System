<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import { getCheckInList, checkIn } from "@/apis/appointment";
import { ElMessage } from "element-plus";
import Stomp from "stompjs";
import SockJS from "sockjs-client";
import { useAdminStore } from "@/stores/admin";

const store = useAdminStore();
const checkInList = ref([]);
const loadingCheckIn = ref(false);
let stompClient = null;

const fetchCheckInList = async () => {
  loadingCheckIn.value = true;
  try {
    const res = await getCheckInList();
    checkInList.value = res.data;
  } catch (error) {
    ElMessage.error("获取报道列表失败");
  } finally {
    loadingCheckIn.value = false;
  }
};

const handleCheckIn = async (id) => {
  try {
    await checkIn(id);
    ElMessage.success("报道成功");
  } catch (error) {
    ElMessage.error("报道失败");
  }
};

const connectWebSocket = () => {
  const socket = new SockJS("/api/ws");
  stompClient = Stomp.over(socket);
  const headers = { token: store.getToken };

  stompClient.connect(
    headers,
    () => {
      stompClient.subscribe("/topic/checkin-list", () => {
        ElMessage.info("报道列表有更新");
        fetchCheckInList();
      });
    },
    (error) => {
      console.error("WebSocket Connection Error:", error);
      ElMessage.error("实时服务连接失败，请刷新页面重试");
    }
  );
};

onMounted(() => {
  fetchCheckInList();
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
          <span>报道列表</span>
        </div>
      </template>
      <el-table :data="checkInList" v-loading="loadingCheckIn">
        <el-table-column
          prop="appointmentDate"
          label="预约日期"
        ></el-table-column>
        <el-table-column prop="startTime" label="开始时间"></el-table-column>
        <el-table-column prop="patientName" label="患者姓名"></el-table-column>
        <el-table-column
          prop="appointmentContent"
          label="预约内容"
        ></el-table-column>
        <el-table-column prop="status" label="状态"></el-table-column>
        <el-table-column label="操作">
          <template #default="scope">
            <el-button
              size="small"
              type="success"
              @click="handleCheckIn(scope.row.id)"
              :disabled="scope.row.status !== 'PENDING'"
              >报道</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>
