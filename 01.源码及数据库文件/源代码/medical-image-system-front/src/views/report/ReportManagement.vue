<script setup>
import { ref, reactive } from "vue";
import {
  getReportsByImageId,
  createReport,
  updateReport,
  deleteReport,
} from "@/apis/report";
import { ElMessage, ElMessageBox } from "element-plus";
import { useAdminStore } from "@/stores/admin";
import { Search, Plus, Edit, Delete } from "@element-plus/icons-vue";

const store = useAdminStore();

const imageIdQuery = ref("");
const reports = ref([]);
const loading = ref(false);
const dialogVisible = ref(false);
const dialogMode = ref("create"); // 'create' or 'edit'

const initialReportForm = {
  id: null,
  imageId: "",
  diagnosis: "",
  suggestion: "",
  content: "",
  generatedBy: store.getAdmin.id,
};

const reportForm = reactive({ ...initialReportForm });

// --- Functions ---
const handleSearch = async () => {
  if (!imageIdQuery.value) {
    ElMessage.info("请输入影像ID进行查询");
    return;
  }
  loading.value = true;
  try {
    const response = await getReportsByImageId(imageIdQuery.value);
    reports.value = response.data;
  } catch (error) {
    ElMessage.error("获取报告列表失败");
  } finally {
    loading.value = false;
  }
};

const openCreateDialog = () => {
  if (!imageIdQuery.value) {
    ElMessage.warning("请先查询一个影像ID以关联新报告");
    return;
  }
  dialogMode.value = "create";
  Object.assign(reportForm, initialReportForm, {
    imageId: imageIdQuery.value,
    generatedBy: store.getAdmin.id,
  });
  dialogVisible.value = true;
};

const openEditDialog = (report) => {
  dialogMode.value = "edit";
  Object.assign(reportForm, report);
  dialogVisible.value = true;
};

const handleDialogSubmit = async () => {
  try {
    if (dialogMode.value === "create") {
      await createReport(reportForm);
      ElMessage.success("报告创建成功");
    } else {
      await updateReport(reportForm);
      ElMessage.success("报告更新成功");
    }
    dialogVisible.value = false;
    handleSearch(); // Refresh the list
  } catch (error) {
    ElMessage.error(
      dialogMode.value === "create" ? "报告创建失败" : "报告更新失败"
    );
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
        handleSearch(); // Refresh the list
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
          <span>报告查询</span>
        </div>
      </template>
      <el-form inline>
        <el-form-item label="影像ID">
          <el-input
            v-model="imageIdQuery"
            placeholder="请输入影像ID"
            clearable
            @keyup.enter="handleSearch"
          ></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleSearch"
            >查询</el-button
          >
          <el-button type="success" :icon="Plus" @click="openCreateDialog"
            >新建报告</el-button
          >
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>报告列表</span>
        </div>
      </template>
      <el-table
        :data="reports"
        v-loading="loading"
        style="width: 100%"
        empty-text="暂无数据，请输入影像ID后点击查询"
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

    <el-dialog
      v-model="dialogVisible"
      :title="dialogMode === 'create' ? '新建报告' : '编辑报告'"
      width="600px"
    >
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
