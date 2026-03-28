<script setup>
import { ref, nextTick } from "vue";
import { ElMessage } from "element-plus";
import { chatWithAi } from "@/apis/ai";
import { Promotion } from "@element-plus/icons-vue";
import { marked } from "marked"; // 导入 marked

const messages = ref([]);
const newMessage = ref("");
const loading = ref(false);
const chatArea = ref(null);

const scrollToBottom = () => {
  nextTick(() => {
    if (chatArea.value) {
      chatArea.value.scrollTop = chatArea.value.scrollHeight;
    }
  });
};

const handleSendMessage = async () => {
  if (!newMessage.value.trim()) {
    ElMessage.info("请输入您的问题");
    return;
  }

  const userMessage = newMessage.value;
  messages.value.push({
    isUser: true,
    text: userMessage,
  });
  newMessage.value = "";
  scrollToBottom();
  loading.value = true;

  try {
    const res = await chatWithAi(userMessage);
    messages.value.push({
      isUser: false,
      text: res.message,
    });
  } catch (error) {
    ElMessage.error("AI服务出错，请稍后再试");
  } finally {
    loading.value = false;
    scrollToBottom();
  }
};
</script>

<template>
  <div class="chat-container">
    <el-card class="chat-card">
      <template #header>
        <div class="card-header">
          <h1>与 Gemini 聊天</h1>
          <p>您可以咨询任何关于医疗影像的问题</p>
        </div>
      </template>
      <div class="chat-area" ref="chatArea">
        <el-scrollbar height="400px">
          <div
            v-for="(msg, index) in messages"
            :key="index"
            class="message-wrapper"
            :class="{ 'user-message': msg.isUser }"
          >
            <div v-if="msg.isUser" class="message-bubble">
              <p>{{ msg.text }}</p>
            </div>
            <div
              v-else
              class="message-bubble markdown-content"
              v-html="marked(msg.text)"
            ></div>
          </div>
          <div v-if="loading" class="message-wrapper">
            <div class="message-bubble">
              <p>Gemini 正在思考...</p>
            </div>
          </div>
        </el-scrollbar>
      </div>
      <div class="chat-input-area">
        <el-input
          v-model="newMessage"
          placeholder="请输入您的问题..."
          @keyup.enter="handleSendMessage"
          size="large"
        >
          <template #append>
            <el-button
              :icon="Promotion"
              @click="handleSendMessage"
              type="primary"
            ></el-button>
          </template>
        </el-input>
      </div>
    </el-card>
  </div>
</template>

<style scoped>
.chat-container {
  padding: 20px;
  height: 100%;
  box-sizing: border-box;
}
.chat-card {
  display: flex;
  flex-direction: column;
  margin-bottom: 0;
  /* height: 100%;
  display: flex;
  flex-direction: column; */
  /* display: flex;
  flex-direction: column;
  margin-bottom: 0;
  height: calc(110vh - 162px); */
}
.card-header h1 {
  margin: 0;
  font-size: 24px;
}
.card-header p {
  margin-top: 8px;
  color: #888;
  font-size: 14px;
}
.chat-area {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background-color: #f9f9f9;
}
.message-wrapper {
  display: flex;
  margin-bottom: 15px;
}
.user-message {
  justify-content: flex-end;
}
.message-bubble {
  padding: 1px 15px;
  border-radius: 18px;
  max-width: 80%;
  background-color: #e3f2fd;
  color: #333;
  line-height: 1.6;
}
.user-message .message-bubble {
  background-color: #409eff;
  color: white;
}
.chat-input-area {
  padding: 15px;
  border-top: 1px solid #e0e0e0;
}

.markdown-content :deep(h1),
.markdown-content :deep(h2),
.markdown-content :deep(h3) {
  margin-top: 1em;
  margin-bottom: 0.5em;
  font-weight: 600;
}
.markdown-content :deep(p) {
  margin: 0.5em 0;
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
.markdown-content :deep(pre) > :deep(code) {
  background-color: transparent;
  padding: 0;
}
.markdown-content :deep(blockquote) {
  border-left: 4px solid #ccc;
  padding-left: 10px;
  margin-left: 0;
  color: #666;
}
</style>
