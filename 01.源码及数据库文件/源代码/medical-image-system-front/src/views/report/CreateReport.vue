<script setup>
import { ref, reactive } from "vue";
import { createReport } from "@/apis/report";
import { searchImages } from "@/apis/image";
import { ElMessage } from "element-plus";
import { useAdminStore } from "@/stores/admin";
import { Search, Plus, Refresh } from "@element-plus/icons-vue";

const store = useAdminStore();

const searchForm = reactive({
  patientName: "",
  patientIdCard: "",
  modality: "",
  tags: "",
  dateRange: [],
});
const searchResults = ref([]);
const selectedImage = ref(null);
const loading = ref(false);
const dialogVisible = ref(false);

const initialReportForm = {
  id: null,
  imageId: "",
  diagnosis: "",
  suggestion: "",
  content: "",
  generatedBy: store.getAdmin.id,
};

const reportForm = reactive({ ...initialReportForm });

const handleSearch = async () => {
  loading.value = true;
  selectedImage.value = null;
  try {
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
  searchForm.patientName = "";
  searchForm.dateRange = "";
  searchForm.modality = "";
  searchForm.patientIdCard = "";
  searchForm.tags = "";
};

const selectImage = (image) => {
  selectedImage.value = image;
  ElMessage.success(`已选择影像ID: ${image.id}`);
};

const openCreateDialog = () => {
  if (!selectedImage.value) {
    ElMessage.warning("请先查询并选择一个影像以创建报告");
    return;
  }
  Object.assign(reportForm, initialReportForm, {
    imageId: selectedImage.value.id,
    generatedBy: store.getAdmin.id,
  });
  dialogVisible.value = true;
};

const handleDialogSubmit = async () => {
  try {
    await createReport(reportForm);
    ElMessage.success("报告创建成功");
    dialogVisible.value = false;
  } catch (error) {
    ElMessage.error("报告创建失败");
  }
};
</script>

<template>
  <div>
    <el-card class="query-card">
      <template #header>
        <div class="card-header">
          <span>创建报告 - 影像查询</span>
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
          <el-button type="primary" :icon="Search" @click="handleSearch"
            >查询影像</el-button
          >
          <el-button @click="handleReset" :icon="Refresh">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>查询结果</span>
          <el-button
            type="success"
            :icon="Plus"
            @click="openCreateDialog"
            :disabled="!selectedImage"
            style="margin-left: auto"
            >新建报告</el-button
          >
        </div>
      </template>
      <el-table
        :data="searchResults"
        v-loading="loading"
        style="width: 100%"
        highlight-current-row
        @current-change="selectImage"
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

    <el-dialog v-model="dialogVisible" title="新建报告" width="600px">
      <el-form :model="reportForm" label-position="top">
        <el-form-item label="影像ID">
          <el-input v-model="reportForm.imageId" disabled />
        </el-form-item>
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
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 18px;
  font-weight: 500;
}
</style>
