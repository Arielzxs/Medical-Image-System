<script setup>
import { reactive, onMounted, ref } from "vue";
import { useRouter } from "vue-router";
import { useAdminStore } from "@/stores/admin";
import { createAppointment, getAvailableSlots } from "@/apis/appointment";
import { ElMessage } from "element-plus";

const store = useAdminStore();
const router = useRouter();
const availableSlots = ref([]);

const appointmentForm = reactive({
  patientId: store.getAdmin.id,
  patientName: store.getAdmin.username,
  patientIdCard: "",
  appointmentDate: "",
  startTime: "",
  appointmentContent: "",
  appointmentType: "",
});

const fetchAvailableSlots = async () => {
  if (appointmentForm.appointmentDate && appointmentForm.appointmentType) {
    try {
      const res = await getAvailableSlots({
        date: appointmentForm.appointmentDate,
        type: appointmentForm.appointmentType,
      });
      availableSlots.value = res.data;
    } catch (error) {
      ElMessage.error("获取可预约时间失败");
    }
  }
};

const handleCreateAppointment = async () => {
  if (
    !appointmentForm.appointmentDate ||
    !appointmentForm.startTime ||
    !appointmentForm.appointmentContent ||
    !appointmentForm.patientIdCard ||
    !appointmentForm.patientName ||
    !appointmentForm.appointmentType
  ) {
    ElMessage.warning("请填写完整的预约信息");
    return;
  }
  try {
    await createAppointment(appointmentForm);
    ElMessage.success("预约成功");
    router.push("/appointment/list");
  } catch (error) {
    ElMessage.error("预约失败，请检查患者信息或该时间段是否已满");
  }
};

const goToList = () => {
  router.push("/appointment/list");
};

onMounted(() => {
  if (store.getAdmin && store.getAdmin.idCard) {
    appointmentForm.patientIdCard = store.getAdmin.idCard;
  }
});
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <span>提交预约</span>
        </div>
      </template>
      <el-form :model="appointmentForm" label-position="top">
        <el-form-item label="患者姓名">
          <el-input
            v-model="appointmentForm.patientName"
            placeholder="请输入患者姓名"
          />
        </el-form-item>
        <el-form-item label="患者身份证">
          <el-input
            v-model="appointmentForm.patientIdCard"
            placeholder="请输入患者身份证"
          />
        </el-form-item>
        <el-form-item label="预约类型">
          <el-input
            v-model="appointmentForm.appointmentType"
            placeholder="例如: CT, X光, 核磁共振"
            @change="fetchAvailableSlots"
          />
        </el-form-item>
        <el-form-item label="预约日期">
          <el-date-picker
            v-model="appointmentForm.appointmentDate"
            type="date"
            placeholder="选择预约日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
            @change="fetchAvailableSlots"
          />
        </el-form-item>
        <el-form-item label="预约时间">
          <el-select
            v-model="appointmentForm.startTime"
            placeholder="请选择时间段"
            style="width: 100%"
          >
            <el-option
              v-for="slot in availableSlots"
              :key="slot"
              :label="`${slot.substring(0, 5)} - ${String(
                parseInt(slot.substring(0, 2)) +
                  (slot.substring(3, 5) === '30' ? 1 : 0)
              ).padStart(2, '0')}:${
                slot.substring(3, 5) === '30' ? '00' : '30'
              }`"
              :value="slot"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="预约内容/备注">
          <el-input
            v-model="appointmentForm.appointmentContent"
            placeholder="请输入预约的详细内容或备注"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleCreateAppointment"
            >提交预约</el-button
          >
          <el-button @click="goToList">查看我的预约</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<style scoped>
.card-header {
  font-size: 18px;
  font-weight: 500;
}
</style>
