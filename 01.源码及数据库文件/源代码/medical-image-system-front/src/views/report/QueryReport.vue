<script setup>
import { ref, reactive } from "vue";
import { getReportsByImageId, updateReport, deleteReport } from "@/apis/report";
import { searchImages } from "@/apis/image";
import { ElMessage, ElMessageBox } from "element-plus";
import { useAdminStore } from "@/stores/admin";
import { Search, Edit, Delete, Refresh } from "@element-plus/icons-vue";

const store = useAdminStore();

// --- State ---
const searchForm = reactive({
  patientName: "",
  patientIdCard: "",
  modality: "",
  tags: "",
  dateRange: [],
});
const searchResults = ref([]);
const reports = ref([]);
const loading = ref(false);
const selectedImage = ref(null);

const dialogVisible = ref(false);
const reportForm = reactive({
  id: null,
  imageId: "",
  diagnosis: "",
  suggestion: "",
  content: "",
  generatedBy: store.getAdmin.id,
});

const handleImageSearch = async () => {
  loading.value = true;
  selectedImage.value = null;
  reports.value = [];
  try {
    // 创建一个干净的参数对象，只包含后端需要的字段
    const params = {
      patientName: searchForm.patientName,
      patientIdCard: searchForm.patientIdCard,
      modality: searchForm.modality,
      tags: searchForm.tags,
      startDate:
        searchForm.dateRange && searchForm.dateRange[0]
          ? searchForm.dateRange[0].toISOString()
          : null,
      endDate:
        searchForm.dateRange && searchForm.dateRange[1]
          ? searchForm.dateRange[1].toISOString()
          : null,
    };

    const res = await searchImages("images", params);
    searchResults.value = res.data;
    if (searchResults.value.length === 0) {
      ElMessage.info("未查询到相关影像");
    }
  } catch (error) {
    ElMessage.error("查询影像失败");
  } finally {
    loading.value = false;
  }
};
const handleReset = () => {
  searchForm.dateRange = "";
  searchForm.modality = "";
  searchForm.patientIdCard = "";
  searchForm.patientName = "";
  searchForm.tags = "";
};
const fetchReportsForImage = async (image) => {
  if (!image) return;
  loading.value = true;
  try {
    const response = await getReportsByImageId(image.id);
    reports.value = response.data;
    if (reports.value.length === 0) {
      ElMessage.info("该影像暂无报告");
    }
  } catch (error) {
    ElMessage.error("获取报告列表失败");
  } finally {
    loading.value = false;
  }
};

const handleImageSelection = (image) => {
  if (!image) {
    selectedImage.value = null;
    reports.value = [];
    return;
  }
  selectedImage.value = image;
  fetchReportsForImage(image);
};

const openEditDialog = (report) => {
  Object.assign(reportForm, report);
  dialogVisible.value = true;
};

const handleDialogSubmit = async () => {
  try {
    await updateReport(reportForm);
    ElMessage.success("报告更新成功");
    dialogVisible.value = false;
    fetchReportsForImage(selectedImage.value);
  } catch (error) {
    ElMessage.error("报告更新失败");
  }
};

const handleDelete = (id) => {
  ElMessageBox.confirm("确定要删除这份报告吗?", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      try {
        await deleteReport(id);
        ElMessage.success("删除成功");
        fetchReportsForImage(selectedImage.value);
      } catch (error) {
        ElMessage.error("删除失败");
      }
    })
    .catch(() => {
      ElMessage.info("已取消删除");
    });
};
</script>

<template>
  <div>
    <el-card class="query-card">
      <template #header>
        <div class="card-header">
          <span>报告查询 - 影像搜索</span>
        </div>
      </template>
      <el-form :model="searchForm" inline>
        <el-form-item label="患者姓名">
          <el-input
            v-model="searchForm.patientName"
            placeholder="请输入患者姓名"
            clearable
          />
        </el-form-item>
        <el-form-item label="患者身份证">
          <el-input
            v-model="searchForm.patientIdCard"
            placeholder="请输入患者身份证"
            clearable
          />
        </el-form-item>
        <el-form-item label="影像类型">
          <el-input
            v-model="searchForm.modality"
            placeholder="例如: X-ray, CT"
            clearable
          />
        </el-form-item>
        <el-form-item label="标签">
          <el-input
            v-model="searchForm.tags"
            placeholder="请输入标签"
            clearable
          />
        </el-form-item>
        <el-form-item label="上传日期">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleImageSearch"
            >查询</el-button
          >
          <el-button @click="handleReset" :icon="Refresh">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>影像列表 (点击一行查看报告)</span>
        </div>
      </template>
      <el-table
        :data="searchResults"
        v-loading="loading"
        style="width: 100%"
        highlight-current-row
        @current-change="handleImageSelection"
      >
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
      </el-table>
    </el-card>

    <el-card style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>报告列表</span>
        </div>
      </template>
      <el-table
        :data="reports"
        v-loading="loading"
        style="width: 100%"
        empty-text="请先从上方列表选择一张影像以查看报告"
      >
        <el-table-column prop="id" label="报告ID" width="100"></el-table-column>
        <el-table-column
          prop="imageId"
          label="影像ID"
          width="100"
        ></el-table-column>
        <el-table-column
          prop="diagnosis"
          label="诊断结论"
          show-overflow-tooltip
        ></el-table-column>
        <el-table-column
          prop="suggestion"
          label="治疗建议"
          show-overflow-tooltip
        ></el-table-column>
        <el-table-column
          prop="createdAt"
          label="创建时间"
          width="200"
        ></el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <el-button
              size="small"
              type="primary"
              :icon="Edit"
              @click="openEditDialog(scope.row)"
              >编辑</el-button
            >
            <el-button
              size="small"
              type="danger"
              :icon="Delete"
              @click="handleDelete(scope.row.id)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" title="编辑报告" width="600px">
      <el-form :model="reportForm" label-position="top">
        <el-form-item label="诊断结论">
          <el-input
            v-model="reportForm.diagnosis"
            type="textarea"
            :rows="3"
          ></el-input>
        </el-form-item>
        <el-form-item label="治疗建议">
          <el-input
            v-model="reportForm.suggestion"
            type="textarea"
            :rows="3"
          ></el-input>
        </el-form-item>
        <el-form-item label="详细内容">
          <el-input
            v-model="reportForm.content"
            type="textarea"
            :rows="6"
          ></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleDialogSubmit">提交</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.query-card {
  margin-bottom: 20px;
}
.card-header {
  font-size: 18px;
  font-weight: 500;
}
</style>
