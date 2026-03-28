<script setup>
import { ref } from "vue";
import { ElMessage, ElLoading } from "element-plus";
import { marked } from "marked";
import { GoogleGenerativeAI } from "@google/generative-ai";

import { UploadFilled, MagicStick, Close } from "@element-plus/icons-vue";

// 配置 Gemini API
// 将 API 密钥直接放在前端代码中存在安全风险。
const API_KEY = "AIzaSyCj729iboHk2LzXCf_DRMmZmBv6WTGG1mI"; // 例如: "AIzaSyCj..."

const genAI = new GoogleGenerativeAI(API_KEY);
const fileUploadModel = genAI.getGenerativeModel({ model: "gemini-2.5-flash" }); // 用于文件上传
const analysisModel = genAI.getGenerativeModel({ model: "gemini-2.5-flash" }); // 用于内容生成

// 定义组件状态
const prompt = ref(
  "请详细描述这些图片中的内容，并分析它们的共同点和不同之处。"
);
const imageFiles = ref([]); // 存储 el-upload 的 File 对象
const analysisResult = ref("");
const loading = ref(false);

// 文件处理方法
const handleFileChange = (file, fileList) => {
  if (file.raw.type.startsWith("image/")) {
    imageFiles.value = fileList;
  } else {
    ElMessage.error("请上传图片格式的文件！");
    // 从列表中移除无效文件
    const invalidFileIndex = fileList.findIndex((f) => f.uid === file.uid);
    if (invalidFileIndex > -1) {
      fileList.splice(invalidFileIndex, 1);
    }
  }
};

const handleFileRemove = (file, fileList) => {
  imageFiles.value = fileList;
};

// 将 el-upload 的 File 对象转换为 Gemini API 需要的格式
async function fileToGenerativePart(file) {
  const base64EncodedDataPromise = new Promise((resolve) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result.split(",")[1]);
    reader.readAsDataURL(file);
  });
  return {
    inlineData: { data: await base64EncodedDataPromise, mimeType: file.type },
  };
}

const handleAnalysis = async () => {
  if (imageFiles.value.length === 0) {
    ElMessage.warning("请至少上传一张图片。");
    return;
  }
  if (!prompt.value.trim()) {
    ElMessage.warning("请输入分析指令。");
    return;
  }
  console.log(imageFiles.value);

  loading.value = true;
  analysisResult.value = "";
  const loadingInstance = ElLoading.service({
    lock: true,
    text: "正在上传影像并请求AI分析...",
    background: "rgba(0, 0, 0, 0.7)",
  });

  try {
    // 将所有选中的文件转换为API需要的格式
    const imageParts = await Promise.all(
      imageFiles.value.map((file) => fileToGenerativePart(file.raw))
    );

    // 构建发送给API的完整请求内容
    const contents = [...imageParts, { text: prompt.value }];

    const promptParts = [...imageParts, { text: prompt.value }];
    // 发送请求
    //   const result = await analysisModel.generateContent({ contents });
    const result = await analysisModel.generateContent({
      contents: [{ parts: promptParts }],
    });
    const response = result.response;
    analysisResult.value = marked(response.text());
  } catch (error) {
    console.error("AI analysis failed:", error);
    ElMessage.error("分析失败，请检查API密钥或网络连接。");
  } finally {
    loading.value = false;
    loadingInstance.close();
  }
};
</script>

<template>
  <div class="analysis-container">
    <h1>多影像智能分析</h1>
    <el-row :gutter="20">
      <el-col :span="10">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>上传影像并输入指令</span>
            </div>
          </template>

          <el-form label-position="top">
            <el-form-item label="第一步：上传需要分析的影像 (可多选)">
              <el-upload
                v-model:file-list="imageFiles"
                class="upload-demo"
                drag
                action="#"
                multiple
                :auto-upload="false"
                :on-change="handleFileChange"
                :on-remove="handleFileRemove"
                list-type="picture"
              >
                <el-icon class="el-icon--upload"><upload-filled /></el-icon>
                <div class="el-upload__text">
                  将文件拖到此处，或<em>点击上传</em>
                </div>
                <template #tip>
                  <div class="el-upload__tip">
                    支持 jpg/png 等图片格式，单张图片建议不超过 10MB
                  </div>
                </template>
              </el-upload>
            </el-form-item>

            <el-form-item label="第二步：输入您的分析指令">
              <el-input
                v-model="prompt"
                type="textarea"
                :rows="4"
                placeholder="例如：请识别这些影像中的病灶，并给出初步诊断建议。"
              />
            </el-form-item>

            <el-form-item>
              <el-button
                type="primary"
                size="large"
                @click="handleAnalysis"
                :loading="loading"
                :icon="MagicStick"
              >
                开始智能分析
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <el-col :span="14">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>分析结果</span>
            </div>
          </template>
          <el-scrollbar height="600px">
            <div
              v-if="analysisResult"
              class="result-content markdown-content"
              v-html="analysisResult"
            ></div>
            <el-empty v-else description="暂无分析结果"></el-empty>
          </el-scrollbar>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.analysis-container {
  padding: 20px;
}
.card-header {
  font-size: 18px;
  font-weight: 500;
}
.result-content {
  line-height: 1.8;
  color: #333;
}
.markdown-content :deep(p) {
  margin: 0.5em 0;
}
.markdown-content :deep(h1),
.markdown-content :deep(h2),
.markdown-content :deep(h3) {
  margin-top: 1em;
  margin-bottom: 0.5em;
  font-weight: 600;
}
.markdown-content :deep(ul),
.markdown-content :deep(ol) {
  padding-left: 20px;
}
.markdown-content :deep(pre) {
  background-color: #f0f0f0;
  padding: 10px;
  border-radius: 6px;
  white-space: pre-wrap;
  word-wrap: break-word;
}
.markdown-content :deep(code) {
  font-family: "Courier New", Courier, monospace;
  background-color: #eee;
  padding: 2px 4px;
  border-radius: 4px;
}
</style>
