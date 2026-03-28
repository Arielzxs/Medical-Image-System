<script setup>
import { reactive, ref } from "vue";
import { ElMessage } from "element-plus";
import { uploadImage } from "@/apis/image";
import { useAdminStore } from "@/stores/admin";
import {
  Plus,
  Refresh,
  User,
  CreditCard,
  CameraFilled,
  PriceTag,
} from "@element-plus/icons-vue";

const store = useAdminStore();

const ruleFormRef = ref();
const uploadComponentRef = ref();

const selectedFile = ref(null);
const localPreviewUrl = ref("");

const getInitialDataForm = () => ({
  patientName: "",
  patientIdCard: "",
  modality: "",
  tags: "",
  uploadedBy: store.getAdmin.id,
  imagePath: "",
});

const dataForm = reactive(getInitialDataForm());

const rules = reactive({
  patientName: [
    { required: true, message: "患者姓名不能为空", trigger: "blur" },
  ],
  patientIdCard: [
    { required: true, message: "患者身份证号不能为空", trigger: "blur" },
    { len: 18, message: "身份证不正确", trigger: "blur" },
  ],
  modality: [{ required: true, message: "影像类型不能为空", trigger: "blur" }],
});

const handleFileChange = (uploadFile) => {
  const rawFile = uploadFile.raw;
  if (!rawFile) return;

  const isImage = ["image/jpeg", "image/png", "image/jpg"].includes(
    rawFile.type
  );
  const isLt10M = rawFile.size / 1024 / 1024 < 10;

  if (!isImage) {
    ElMessage.error("上传影像格式必须是 JPG, PNG 或 JPEG!");
    handleReset();
    return;
  }
  if (!isLt10M) {
    ElMessage.error("上传影像大小不能超过 10MB!");
    handleReset();
    return;
  }

  selectedFile.value = rawFile;
  localPreviewUrl.value = URL.createObjectURL(rawFile);
};

const submitForm = async () => {
  await ruleFormRef.value.validate(async (valid) => {
    if (valid) {
      if (!selectedFile.value) {
        ElMessage.warning("请先选择要上传的影像文件");
        return;
      }

      ElMessage.info("正在上传影像，请稍候...");
      const formData = new FormData();
      formData.append("image", selectedFile.value);
      formData.append("patientName", dataForm.patientName);
      formData.append("patientIdCard", dataForm.patientIdCard);
      formData.append("modality", dataForm.modality);
      formData.append("tags", dataForm.tags);
      formData.append("uploadedBy", dataForm.uploadedBy);

      try {
        const result = await uploadImage(formData);

        if (result.state === 0) {
          dataForm.imagePath = result.data;
          ElMessage.success("影像上传成功!");
          handleReset(); // 上传成功后也重置表单
        } else {
          ElMessage.error(result.message || "影像上传失败");
        }
      } catch (error) {
        ElMessage.error("上传请求失败，请检查网络或联系管理员");
      }
    } else {
      console.log("表单校验失败");
    }
  });
};

// 重置功能
const handleReset = () => {
  // 重置表单字段
  if (ruleFormRef.value) {
    ruleFormRef.value.resetFields();
  }
  // 清除文件相关状态
  selectedFile.value = null;
  localPreviewUrl.value = "";
  if (uploadComponentRef.value) {
    uploadComponentRef.value.clearFiles();
  }
  Object.assign(dataForm, getInitialDataForm());
};
</script>

<template>
  <div class="upload-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <h1>医疗影像上传</h1>
          <p class="subtitle">请填写患者及影像的相关信息，并上传影像文件。</p>
        </div>
      </template>

      <el-form
        ref="ruleFormRef"
        :model="dataForm"
        :rules="rules"
        label-width="120px"
        label-position="top"
      >
        <el-row :gutter="30">
          <el-col :span="12">
            <el-card shadow="never" class="form-section-card">
              <template #header
                ><div class="section-header">患者信息</div></template
              >
              <el-form-item label="患者姓名" prop="patientName">
                <el-input
                  v-model="dataForm.patientName"
                  placeholder="请输入患者姓名"
                  :prefix-icon="User"
                />
              </el-form-item>
              <el-form-item label="患者身份证号" prop="patientIdCard">
                <el-input
                  v-model="dataForm.patientIdCard"
                  placeholder="请输入患者身份证号"
                  :prefix-icon="CreditCard"
                />
              </el-form-item>
            </el-card>

            <el-card
              shadow="never"
              class="form-section-card"
              style="margin-top: 20px"
            >
              <template #header
                ><div class="section-header">影像详情</div></template
              >
              <el-form-item label="影像类型" prop="modality">
                <el-input
                  v-model="dataForm.modality"
                  placeholder="例如: X-ray, CT, MRI"
                  :prefix-icon="CameraFilled"
                />
              </el-form-item>
              <el-form-item label="标签" prop="tags">
                <el-input
                  v-model="dataForm.tags"
                  placeholder="多个标签请用逗号分隔"
                  :prefix-icon="PriceTag"
                />
              </el-form-item>
            </el-card>
          </el-col>

          <el-col :span="12">
            <el-card shadow="never" class="form-section-card uploader-card">
              <template #header
                ><div class="section-header">文件上传</div></template
              >
              <el-form-item label="影像文件" required>
                <el-upload
                  ref="uploadComponentRef"
                  class="avatar-uploader"
                  action=""
                  :auto-upload="false"
                  :show-file-list="false"
                  :on-change="handleFileChange"
                >
                  <img
                    v-if="localPreviewUrl"
                    :src="localPreviewUrl"
                    class="avatar"
                  />
                  <div v-else class="upload-placeholder">
                    <el-icon class="avatar-uploader-icon"><Plus /></el-icon>
                    <div class="el-upload__text">点击或拖拽文件到此处</div>
                    <div class="el-upload__tip">
                      仅支持 JPG/PNG/JPEG 格式，且不超过10MB
                    </div>
                  </div>
                </el-upload>
              </el-form-item>
            </el-card>
          </el-col>
        </el-row>

        <el-divider />

        <el-form-item class="form-actions">
          <el-button type="primary" size="large" @click="submitForm"
            >确认上传</el-button
          >
          <el-button :icon="Refresh" size="large" @click="handleReset"
            >重置表单</el-button
          >
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<style scoped>
.upload-container {
  padding: 20px;
}
.card-header h1 {
  margin: 0;
  font-size: 24px;
}
.card-header .subtitle {
  margin-top: 8px;
  color: #888;
  font-size: 14px;
}
.form-section-card {
  border: none;
  background-color: #fcfcfc;
}
.section-header {
  font-size: 16px;
  font-weight: 500;
}
.uploader-card {
  height: 100%;
}
.avatar-uploader .avatar {
  width: 100%;
  height: 280px;
  object-fit: contain;
  display: block;
}
:deep(.avatar-uploader .el-upload) {
  border: 2px dashed var(--el-border-color);
  border-radius: 10px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: var(--el-transition-duration-fast);
  width: 100%;
  height: 280px;
  display: flex;
  align-items: center;
  justify-content: center;
}
:deep(.avatar-uploader .el-upload:hover) {
  border-color: var(--el-color-primary);
}
.upload-placeholder {
  text-align: center;
  color: #8c939d;
}
.avatar-uploader-icon {
  font-size: 48px;
  margin-bottom: 16px;
}
.el-upload__text {
  font-size: 14px;
  line-height: 1.5;
}
.el-upload__tip {
  font-size: 12px;
  margin-top: 8px;
}
.form-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
