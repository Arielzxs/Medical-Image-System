<script setup>
import { reactive, ref, computed } from "vue";
import {
  searchImages,
  searchImagesByPatientId,
  deleteImage,
} from "@/apis/image";
import { shareImage } from "@/apis/share";
import { getReportsByImageId } from "@/apis/report";
import { useAdminStore } from "@/stores/admin";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Search,
  Share,
  View as ViewIcon,
  Delete,
  Refresh,
} from "@element-plus/icons-vue"; // 重命名导入的View图标

const store = useAdminStore();
const userRole = computed(() => store.getAdmin.role);
const userId = computed(() => store.getAdmin.id);

const searchForm = reactive({
  searchType: "by-patient-name",
  keyword: "",
  startDate: "",
  endDate: "",
});
const searchResults = ref([]);
const loading = ref(false);

const shareDialogVisible = ref(false);
const shareForm = reactive({
  imageId: null,
  sharedTo: "",
  sharedBy: store.getAdmin.id,
});

const reportDialogVisible = ref(false);
const selectedImageReports = ref([]);
const reportLoading = ref(false);

const openShareDialog = (row) => {
  shareForm.imageId = row.id;
  shareForm.sharedTo = "";
  shareDialogVisible.value = true;
};

const handleShareSubmit = async () => {
  if (!shareForm.sharedTo) {
    ElMessage.error("请输入要分享的用户ID");
    return;
  }
  try {
    await shareImage({
      imageId: shareForm.imageId,
      sharedBy: shareForm.sharedBy,
      sharedTo: shareForm.sharedTo,
    });
    ElMessage.success("影像分享成功!");
    shareDialogVisible.value = false;
  } catch (error) {
    ElMessage.error("影像分享失败!");
  }
};

const openReportDialog = async (row) => {
  reportLoading.value = true;
  reportDialogVisible.value = true;
  try {
    const res = await getReportsByImageId(row.id);
    selectedImageReports.value = res.data;
  } catch (error) {
    ElMessage.error("获取报告失败");
  } finally {
    reportLoading.value = false;
  }
};

const viewImage = (filePath) => {
  const imageUrl = `http://localhost:8080${filePath}`;
  window.open(imageUrl, "_blank");
};

const paramNameMapping = {
  "by-patient-name": "PatientName",
  "by-uploaded-name": "UploadedName",
  by_patient_id_card: "IdCard",
};

const handleSearch = async () => {
  loading.value = true;
  try {
    if (userRole.value === "patient") {
      const res = await searchImagesByPatientId(userId.value);
      searchResults.value = res.data;
    } else {
      let params = {};
      if (searchForm.searchType === "by-date-range") {
        params = {
          startDate: searchForm.startDate,
          endDate: searchForm.endDate,
        };
      } else {
        const paramName = paramNameMapping[searchForm.searchType];
        params = {
          [paramName]: searchForm.keyword,
        };
      }
      const res = await searchImages(searchForm.searchType, params);
      searchResults.value = res.data;
    }
  } catch (error) {
    ElMessage.error("查询失败!");
  } finally {
    loading.value = false;
  }
};

const handleDelete = (id) => {
  ElMessageBox.confirm("确定要删除该影像吗？", "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      try {
        await deleteImage(id);
        ElMessage.success("删除成功!");
        handleSearch(); // Refresh the list
      } catch (error) {
        ElMessage.error("删除失败!");
      }
    })
    .catch(() => {
      ElMessage.info("已取消删除");
    });
};

const handleReset = () => {
  searchForm.endDate = "";
  searchForm.keyword = "";
  searchForm.searchType = "by-patient-name";
  searchForm.startDate = "";
};
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <span>影像检索与查询</span>
        </div>
      </template>
      <el-form :model="searchForm" inline v-if="userRole !== 'patient'">
        <el-form-item label="查询类型">
          <el-select v-model="searchForm.searchType" style="width: 150px">
            <el-option label="患者姓名" value="by-patient-name"></el-option>
            <el-option label="上传者姓名" value="by-uploaded-name"></el-option>
            <el-option
              label="患者身份证"
              value="by_patient_id_card"
            ></el-option>
            <el-option label="日期范围" value="by-date-range"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item
          v-if="searchForm.searchType !== 'by-date-range'"
          label="关键词"
        >
          <el-input v-model="searchForm.keyword" placeholder="请输入关键词" />
        </el-form-item>
        <el-form-item
          v-if="searchForm.searchType === 'by-date-range'"
          label="开始日期"
        >
          <el-date-picker
            v-model="searchForm.startDate"
            type="datetime"
            placeholder="选择开始日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item
          v-if="searchForm.searchType === 'by-date-range'"
          label="结束日期"
        >
          <el-date-picker
            v-model="searchForm.endDate"
            type="datetime"
            placeholder="选择结束日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleSearch"
            >查询</el-button
          >
          <el-button :icon="Refresh" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
      <div v-else>
        <el-button type="primary" :icon="Search" @click="handleSearch"
          >查询我的影像</el-button
        >
      </div>
    </el-card>

    <el-card>
      <el-table :data="searchResults" v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column
          prop="patientName"
          label="患者姓名"
          width="120"
        ></el-table-column>
        <el-table-column prop="modality" label="影像类型"></el-table-column>
        <el-table-column prop="tags" label="标签"></el-table-column>
        <el-table-column
          prop="uploadedName"
          label="上传者"
          width="120"
        ></el-table-column>
        <el-table-column prop="uploadedAt" label="上传时间"></el-table-column>
        <el-table-column label="操作" width="400">
          <template #default="scope">
            <el-button
              size="small"
              type="primary"
              :icon="ViewIcon"
              @click="viewImage(scope.row.filePath)"
            >
              查看影像
            </el-button>
            <el-button
              size="small"
              type="info"
              :icon="ViewIcon"
              @click="openReportDialog(scope.row)"
              >查看报告</el-button
            >
            <el-button
              size="small"
              type="success"
              :icon="Share"
              @click="openShareDialog(scope.row)"
              >分享</el-button
            >
            <el-button
              size="small"
              type="danger"
              :icon="Delete"
              @click="handleDelete(scope.row.id)"
              v-if="userRole !== 'patient'"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="shareDialogVisible" title="分享影像" width="400px">
      <el-form :model="shareForm" label-position="top">
        <el-form-item label="分享给 (用户ID)">
          <el-input v-model="shareForm.sharedTo" autocomplete="off" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="shareDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleShareSubmit"
            >确认分享</el-button
          >
        </span>
      </template>
    </el-dialog>

    <el-dialog v-model="reportDialogVisible" title="影像报告" width="600px">
      <div v-loading="reportLoading">
        <div v-if="selectedImageReports.length > 0">
          <el-card
            v-for="report in selectedImageReports"
            :key="report.id"
            style="margin-bottom: 15px"
          >
            <p><strong>诊断结论:</strong> {{ report.diagnosis }}</p>
            <p><strong>治疗建议:</strong> {{ report.suggestion }}</p>
            <p><strong>详细内容:</strong> {{ report.content }}</p>
            <p>
              <small>报告生成时间: {{ report.createdAt }}</small>
            </p>
          </el-card>
        </div>
        <el-empty v-else description="暂无相关报告"></el-empty>
      </div>
    </el-dialog>
  </div>
</template>

<style scoped>
.card-header {
  font-size: 18px;
  font-weight: 500;
}
</style>
