<script setup>
import { ref, reactive, onMounted } from "vue";
import { getLogPage, deleteLog } from "@/apis/log";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Search,
  Share,
  View as ViewIcon,
  Delete,
  Refresh,
} from "@element-plus/icons-vue"; // 重命名导入的View图标
const searchForm = reactive({
  username: "",
  operation: "",
  dateRange: [],
});

const pageNo = ref(1);
const pageSize = ref(10);
const total = ref(0);

const tableData = ref([]);
const loading = ref(false);

const searchLogPage = async () => {
  loading.value = true;
  try {
    const params = {
      pageNo: pageNo.value,
      pageSize: pageSize.value,
      username: searchForm.username,
      operation: searchForm.operation,
      startDate:
        searchForm.dateRange && searchForm.dateRange[0]
          ? searchForm.dateRange[0].toISOString()
          : null,
      endDate:
        searchForm.dateRange && searchForm.dateRange[1]
          ? searchForm.dateRange[1].toISOString()
          : null,
    };
    const result = await getLogPage(params);
    tableData.value = result.data.records;
    total.value = result.data.total;
  } catch (error) {
    ElMessage.error("获取日志列表失败");
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  searchLogPage();
});

const handleSearch = () => {
  pageNo.value = 1;
  searchLogPage();
};

const handleReset = () => {
  searchForm.username = "";
  searchForm.operation = "";
  searchForm.dateRange = [];
  handleSearch();
};

const handleSizeChange = (value) => {
  pageSize.value = value;
  searchLogPage();
};

const handleCurrentChange = (value) => {
  pageNo.value = value;
  searchLogPage();
};

const handleDelete = (id) => {
  ElMessageBox.confirm("确定要删除这条日志吗?", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      try {
        await deleteLog(id);
        ElMessage.success("删除成功");
        searchLogPage();
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
  <h1>用户操作日志</h1>
  <el-card>
    <div class="header-controls">
      <el-input
        v-model="searchForm.username"
        placeholder="请输入用户名"
        class="searchInput"
        clearable
      />
      <el-input
        v-model="searchForm.operation"
        placeholder="请输入操作内容"
        class="searchInput"
        clearable
      />
      <el-date-picker
        v-model="searchForm.dateRange"
        type="datetimerange"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
      />
      <el-button :icon="Search" type="primary" @click="handleSearch"
        >查询</el-button
      >
      <el-button :icon="Refresh" @click="handleReset">重置</el-button>
    </div>
  </el-card>
  <el-card>
    <el-table :data="tableData" v-loading="loading" style="width: 100%">
      <el-table-column prop="id" label="编号" width="80" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="operation" label="操作" show-overflow-tooltip />
      <el-table-column prop="ipAddress" label="IP地址" width="150" />
      <el-table-column prop="createdAt" label="操作时间" width="180" />
      <el-table-column fixed="right" label="操作" width="100">
        <template #default="scope">
          <el-button
            type="danger"
            size="small"
            @click="handleDelete(scope.row.id)"
            >删除</el-button
          >
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="pageNo"
      v-model:page-size="pageSize"
      :page-sizes="[10, 20, 50, 100]"
      background
      layout="total, sizes, prev, pager, next, jumper"
      :total="total"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
      style="margin-top: 20px"
    />
  </el-card>
</template>

<style scoped>
.header-controls {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-bottom: 20px;
}
.searchInput {
  width: 240px;
}
</style>
