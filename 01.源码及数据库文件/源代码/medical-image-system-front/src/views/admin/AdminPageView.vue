<script setup>
import { ref, onMounted, reactive } from "vue";
import { adminPage, adminDeleteById } from "@/apis/user";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import {
  Search,
  Share,
  View as ViewIcon,
  Delete,
  Refresh,
} from "@element-plus/icons-vue"; // 重命名导入的View图标
const searchForm = reactive({
  username: "",
  phone: "",
  idCard: "",
  role: "",
});

const pageNo = ref(1);
const pageSize = ref(5);
const total = ref(0);
const router = useRouter();

const tableData = ref([]);
const loading = ref(false);

const searchAdminPage = async () => {
  loading.value = true;
  try {
    const params = {
      pageNo: pageNo.value,
      pageSize: pageSize.value,
      ...searchForm,
    };
    const result = await adminPage(params);
    tableData.value = result.data.records;
    total.value = result.data.total;
  } catch (error) {
    ElMessage.error("获取用户列表失败");
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  searchAdminPage();
});

const handleReset = () => {
  searchForm.username = "";
  searchForm.phone = "";
  searchForm.idCard = "";
  searchForm.role = "";
  handleSearch();
};

const formatGender = (row) => {
  return row.gender === 0 ? "男" : row.gender === 1 ? "女" : "未知";
};

const handleSearch = () => {
  pageNo.value = 1;
  searchAdminPage();
};

const handleSizeChange = (value) => {
  pageSize.value = value;
  searchAdminPage();
};

const handleCurrentChange = (value) => {
  pageNo.value = value;
  searchAdminPage();
};

const handleAdd = () => {
  router.push({
    path: "/admin/add",
  });
};

const handleUpdate = (id) => {
  router.push({
    path: "/admin/edit",
    query: { id },
  });
};

const handleConfirmDelete = async (id) => {
  try {
    await adminDeleteById(id);
    ElMessage.success("删除用户成功");
    searchAdminPage();
  } catch (error) {
    ElMessage.error("删除用户失败");
  }
};
</script>

<template>
  <h1>管理员用户列表</h1>
  <el-card>
    <div class="header-controls">
      <el-input
        v-model="searchForm.username"
        placeholder="请输入用户名"
        class="searchInput"
        @keyup.enter="handleSearch"
        clearable
      />
      <el-input
        v-model="searchForm.phone"
        placeholder="请输入电话"
        class="searchInput"
        @keyup.enter="handleSearch"
        clearable
      />
      <el-input
        v-model="searchForm.idCard"
        placeholder="请输入身份证号"
        class="searchInput"
        @keyup.enter="handleSearch"
        clearable
      />
      <el-select
        v-model="searchForm.role"
        placeholder="请选择角色"
        clearable
        class="searchInput"
      >
        <el-option label="普通医生" value="doctor"></el-option>
        <el-option label="专家" value="expert"></el-option>
        <el-option label="管理员" value="admin"></el-option>
        <el-option label="患者" value="patient"></el-option>
      </el-select>
      <el-button :icon="Search" type="primary" @click="handleSearch"
        >查询</el-button
      >

      <el-button :icon="Refresh" @click="handleReset">重置</el-button>

      <el-button type="success" @click="handleAdd">新增用户</el-button>
    </div>
  </el-card>
  <el-card>
    <el-table :data="tableData" v-loading="loading" style="width: 100%">
      <el-table-column prop="id" label="编号" width="80" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="age" label="年龄" width="80" />
      <el-table-column
        prop="gender"
        label="性别"
        width="80"
        :formatter="formatGender"
      />
      <el-table-column prop="phone" label="电话" width="150" />
      <el-table-column prop="birthDate" label="生日" width="120" />
      <el-table-column prop="address" label="地址" show-overflow-tooltip />
      <el-table-column prop="role" label="角色" width="100" />
      <el-table-column prop="idCard" label="身份证号" width="180" />
      <el-table-column prop="createdAt" label="创建时间" width="180" />
      <el-table-column fixed="right" label="操作" width="150">
        <template #default="scope">
          <el-button
            type="primary"
            size="small"
            @click="handleUpdate(scope.row.id)"
            >编辑</el-button
          >
          <el-popconfirm
            confirm-button-text="确定"
            cancel-button-text="取消"
            icon-color="#626AEF"
            title="确定要删除该用户吗?"
            @confirm="handleConfirmDelete(scope.row.id)"
          >
            <template #reference>
              <el-button type="danger" size="small">删除</el-button>
            </template>
          </el-popconfirm>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="pageNo"
      v-model:page-size="pageSize"
      :page-sizes="[5, 10, 20, 50]"
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
  width: 200px;
}
</style>
